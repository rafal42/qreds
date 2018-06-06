module GrapeReducers
  module Endpoint
    def sort(collection, **args)
      apply(:sort, collection, :order, args)
    end

    def filter(collection, **args)
      apply(:filters, collection, :where, args)
    end

    private

    def apply(key, collection, fallback_method, **args)
      declared_params = declared(params, include_missing: false)[key]

      ::GrapeReducers::Reducer.new(
        functor_group: key,
        collection: collection,
        reducible: declared_params,
        fallback_method: fallback_method,
        **args
      ).call
    end
  end
end
