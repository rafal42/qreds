module GrapeReducers
  module Endpoint
    def method_missing(name, collection, **args, &_)
      config = ::GrapeReducers::Config[name]
      params_group_name = config[:params_group_name]
      declared_params = declared(params, include_missing: false)[params_group_name]

      ::GrapeReducers::Reducer.new(
        functor_group: params_group_name,
        collection: collection,
        params: declared_params,
        config: config,
        **args
      ).call
    end
  end
end
