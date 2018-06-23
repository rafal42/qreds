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

```
class TestApi < Grape::API
  helpers Qreds::Endpoint

  format :json
  prefix :api

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
      (sort filter(Product.all)).pluck(:name, :value)
    end
  end
end
```

This definition would enable you to make requests with the specified params, and they'll work out of the box by applying `.where` or `.order` with the given values. So for example, if you pass `{ "filters": { "value_eq": 42 } }`, you'd get only records where the `field` value is equal to 42.

You can of course define custom reducers, like the filters or sort specified above. If that's what you're looking for, keep reading.

## Built-in reducers

### `filter` reducer

`Qreds::Endpoint` exposes the `filter` method. It looks for functors in the following namespace:
`Filters::{resource_name}::{functor_name}`.

It is a reducer with a default lambda suited to work with ActiveRecord, and an operator mapping suited to work with PostgreSQL. For basic operations, you don't need to define a custom functor, but can take advantage of the mapping. Example params with all available suffixes.

```
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
```
'sort' => {
  'value' => 'asc', # sorts by value ascending
  'value' => 'desc', # sorts by value descending
}
```

## Custom filtering/sorting

You might need to write some more complex logic to reduce your query. To do that, you can subclass the `Qreds::Functor` class:

```
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
```
{
  "filters": {
    "custom_value_filter": 42
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
- `config.default_lambda(query, attr_name, value, operator)` - defines the lambda which is used every time when a matchinc class cannot be found; Receives the query, name of the attribute (`key`), the value of the attribute (`value`), the `operator` transformed with `operator_mapping` (if the mapping is present).


### Namespace lookup

The reducers use the following schema for looking up Functors:

`{functor_group}::{resource_name}::{functor_name}`, where:
- `functor_group` can be passed when defining a reducer
- `resource_name` defaults to `query.model.to_s`, but can be overridden (eg. when invoking `filter(query, resource_name: 'ResourceName'))`
- `functor_name` is the key in params; eg, for `{ "filters": { "something": 42 } }`, the `functor_name` is `'something'`

### Order of application

Functors transform the query in the order that respective params have been passed. For example:
```
'sort' => {
  'value' => 'asc',
  'name' => 'desc'
}
```

Will at first apply `order('value asc')`, then `order('name desc')`

### Defining a reducer

Qreds exposes an interface to define a new reducer. Take a look at an example:

```
Qreds::Config.define_reducer :elasticsearch_filter do |config|
  config.operator_mapping = {} # optional; if defined, will raise an error when an undefined suffix is provided
  config.functor_group = :elasticsearch_filters # optional, defaults to the name passed as `define_reducer` argument
  config.default_lambda = ->(query, attr_name, value, _operator) do
    {
      **query,
      attr_name => value
    }
  end
end
```

This would define a reducer which is accessible from `Qreds::Endpoint` with the `elasticsearch_filter` method.
