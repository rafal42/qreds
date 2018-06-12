# Introduction

Qreds is an architectural boilerplate for implementing query reducers,
and a set of built-in query reducers for ActiveRecord Relations.

Qreds is suited to work seamlessly with Grape.

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

This definition would enable you to make requests with the specified params, and they'll work out of the box by applying `.where` or `.order` with the passed params.
You can of course define custom reducers, like the filters or sort specified above. If that's what you're looking for, keep reading.

## Advanced

To get the full advantage of Qreds, you need to accustom yourself with the basic concepts.

When you use the `filter` or `sort` helpers, you are in fact using a `filter` or `sort` reducer. These two are defined by default and are suited to work with ActiveRecord.

Let's consider the `filter` reducer as an example to learn how the abstraction works.

1) `filter` fetches `declared` params under the `filters` key
2) declared params are then passed on to the generic Reducer along with the query
3) for each parameter (`key => value` pair) the generic Reducer tries to fetch a matching class
4) if a matching class (called a Functor) is found, it is passed the `query` and the `value` from the pair
5) if a Functor is not found, then a default lambda from the specific reducer config is used to transform the query

So, with the following declared params: `{ "filters": { "value": 42 } }`, and the query passed to the `filter` helper being `Product::ActiveRecord_Relation`, the generic Reducer would try to fetch a functor named `Filters::Product::Value`.

The functor is a plain old Ruby object. You can subclass `Qreds::Functor` to get access to the Functor interface.
The `Functor` has two attributes and private attr_readers: `query` and `value`. In our example, `query` is a `Product::ActiveRecord_Relation`, and `value` is 42.

```
module Filters
  module Product
    class Value < ::Qreds::Functor
      def call
        query.where('value > ?', value - 10)
      end
    end
  end
end
```

Let's now consider another value of params: `{ "filters": { "value_eq": 42} }`.
If we didn't define the Functor `Filters::Product::ValueEq` it couldn't be found. Instead, the work is directed to a catch-all Functor. Now, depending on the reducer's config (in this case - the `filter` reducer's config), the following come into play:
- `config.operator_mapping` - defines how suffixes should be translated; the `filter` reducer defines, for example, it maps the `eq` suffix to `=` for use in AR queries; so when the `value_eq` is passed, the final result of the functor is roughly: `query.where('value = ?', value)`.
- `config.default_lambda(query, attr_name, value, operator)` - defines the lambda which is used every time when a Functor cannot be found; so when the catch-all functor executes, it delegates the logic to the lambda. Receives the query, name of the attribute (params `key`), the value of the attribute (`value`), the `operator` transformed with `operator_mapping` (if the mapping is present).


### Namespace lookup

The reducers use the following schema for looking up Functors:

`{functor_group}::{resource_name}::{functor_name}`, where:
- `functor_group` is passed when defining the reducer
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
