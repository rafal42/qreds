module GrapeReducers
  module Endpoint
    def method_missing(name, collection, **args, &_)
      config = ::GrapeReducers::Config[name]
      functor_group = config[:functor_group]

      declared_params = declared(params, include_missing: false)[functor_group]

      ::GrapeReducers::Reducer.new(
        collection: collection,
        params: declared_params,
        config: config,
        **args
      ).call
    end
  end
end
