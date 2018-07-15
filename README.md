# Introduction

Qreds is an architectural boilerplate for implementing query reducers,
and a set of built-in query reducers for ActiveRecord Relations.

Qreds is a ready-to-go solution for Grape.

## Quickstart

### Installation

Add the gem to your `Gemfile`:
`gem qreds`

and run `bundle install`.

### Example usage (ActiveRecord)

Assume you have a model named `Product`, with fields `name: String` and `value: Integer`. Now, you'd like to enable filtering and sorting in a Grape endpoint on that particular model. You can do so with the following code:

```ruby
class TestApi < Grape::API
  helpers Qreds::Endpoint

  resources :products do
    params do
      optional :filters, type: Hash do
        optional :name_in, type: Array[String]
        optional :value_eq, type: Integer
        optional :value_gte, type: Integer
      end
      optional :sort, type: Hash do
        optional :name, type: String
        optional :value, type: String
      end
    end
    get do
      sort filter(Product.all)
    end
  end
end
```

This definition would enable you to make requests with the specified params, and they'll work out of the box by applying `.where` or `.order` with the given values. So for example, if you pass `{ "filters": { "value_eq": 42 } }`, you'd get only records where the `field` value is equal to 42.

Qreds has built-in support for such filters and sorting for ActiveRecord, but also enables you to write custom AR filters / sorting, and define other reducer types to handle different cases (for example, if you'd want some other behaviour for ElasticSearch based endpoints).

#### Association reducers

What if you just added a new association to `Product`:

```ruby
class Product
  has_many :offers
end
```

And wanted to filter all products that have offers with `value` less than some particular value?
No problem, we've got you covered.

```ruby
params do
  optional :filters, type: Hash do
    optional :'offers.value_lt', type: Integer
  end
end
```

Now, when the endpoint receives `{"filters": {"offers.value_lt": 42 } }`, it will return all products that have an offer with value less than 42. Qreds takes care of automatically joining the required tables and applying `group(:id)` to get rid of possible duplicates.

## Built-in reducers

### `filter` reducer

`Qreds::Endpoint` exposes the `filter` method. It looks for functors in the following namespace:
`Filters::{resource_name}::{functor_name}`.

It is a reducer with a default lambda suited to work with ActiveRecord, and an operator mapping suited to work with PostgreSQL. For basic operations, you don't need to define a custom functor, but can take advantage of the mapping. Example params with all available suffixes.

```ruby
'filters' => {
  'value_lt' => 42, # filters all records where value is less than 42
  'value_lte' => 42, # filters all records where value is less than or equal to 42
  'value_eq' => 42, # filters all records where value is equal to 42
  'value_gt' => 42, # filters all records where value is greater than 42
  'value_gte' => 42, # filters all records where value is greater than or equal to 42
  'value_in' => [41, 42, 43], # filters all records where value is any of: 41, 42, 43
  'value_btw' => [42, 43] # filters all records where value is between 42 and 43 (inclusive)
}
```

### `sort` reducer

`Qreds::Endpoint` exposes the `sort` method. It looks for functors in the following namespace:
`Sort::{resource_name}::{functor_name}`.

It is a reducer with a default lambda suited to work with ActiveRecord, with no operator mapping. It will accept any values that ActiveRecord `order` accepts for values, so `'desc'` or `'asc'` are good to go. Example params:
```ruby
'sort' => {
  'value' => 'asc', # sorts by value ascending
  'value' => 'desc', # sorts by value descending
}
```

## Custom filtering/sorting

You might need to write some more complex logic to reduce your query. To do that, you can subclass the `Qreds::Functor` class:

```ruby
module Filters
  module Product
    class CustomValueFilter < ::Qreds::Functor
      def call
        query.where('value > ?', context[:user].admin? ? value - 10 : value - 5)
      end
    end
  end
end
```

So, if you had the params:
```ruby
{
  'filters' => {
    'custom_value_filter' => 42
  }
}
```

And you called: `filter(Product.all, context: { user: current_user })`, then an instance of the custom filter above would be created, and would have access to:
`query` - `Product::ActiveRecord_Relation` (result of `Product.all`)
`value` - `42`
`context` -  `{ user: current_user }` context hash

## Advanced

To leverage the full advantage of Qreds, you need to accustom yourself with the concepts.

When you use the `filter` or `sort` helpers, you are in fact using a `filter` or `sort` reducer. These two are defined by default and are suited to work with ActiveRecord.

Let's consider the `filter` reducer as an example to learn how the abstraction works.

1) `filter` fetches `declared` params under the `filters` key
2) declared params are then processed along the query you passed (`filter(Product.all)`)
3) for each parameter (`key => value` pair) we try to find a class, matching the `key` (eg. when the key is `value`, we look for `Filters::Product::Value`)
4) if a matching class is found, it transforms the `query` according to the `value`
5) if a matching class is not found, then a default lambda from the specific reducer config is used to transform the query.

So, with the following declared params: `{ "filters": { "value": 42 } }`, and the query passed to the `filter` helper being `Product::ActiveRecord_Relation`, we would try to find a class named `Filters::Product::Value`.

Now, depending on the specific reducer's config (in this case - the `filter` reducer's config), the following come into play:

- `config.operator_mapping` - defines how parameter name suffixes should be translated; the `filter` reducer defines, for example, that the `_eq` suffix to should mean `=` for usage in ActiveRecord queries; so when the `value_eq` is passed, the final result of applying the transformation is roughly: `query.where('value = ?', value)`.
- `config.default_lambda(query, attr_name, value, operator, context)` - defines the lambda which is used every time when a matchinc class cannot be found; Receives the query, name of the attribute (`key`), the value of the attribute (`value`), the `operator` transformed with `operator_mapping` (if the mapping is present).


### Namespace lookup

The reducers use the following schema for looking up Functors:

`{functor_group}::{resource_name}::{functor_name}`, where:
- `functor_group` can be passed when defining a reducer
- `resource_name` defaults to `query.model.to_s`, but can be overridden (eg. when invoking `filter(query, resource_name: 'ResourceName'))`
- `functor_name` is the key in params; eg, for `{ "filters": { "something": 42 } }`, the `functor_name` is `'something'`

### Order of application

Functors transform the query in the order of params declaration. For example, having:

```ruby
optional :sort, type: Hash do
  optional :x, type: String
  optional :y, type: String
end
```

Calling `sort` on a collection would first apply `order(x => value)`, then `order(y => value)` (if both are present).

### Defining a reducer

Qreds exposes an interface to define a new reducer. Take a look at an example:

```ruby
Qreds::Config.define_reducer :elasticsearch_filter do |config|
  config.operator_mapping = {} # optional; if defined, will raise an error when an undefined suffix is provided
  config.functor_group = :elasticsearch_filters # optional, defaults to the name passed as `define_reducer` argument
  config.default_lambda = ->(query, attr_name, value, _operator, _context) do
    {
      **query,
      attr_name => value
    }
  end
end
```

This would define a reducer which is accessible from `Qreds::Endpoint` with the `elasticsearch_filter` method.
