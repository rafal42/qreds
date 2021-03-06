module Qreds
  class Reducer
    # @param query [any] the query to be reduced
    # @param params [Hash] with keys being functor names and values the functor arguments.
    # @param config [Qreds::Config] current reducer config
    # @param resource_name [String] the name of the resource that query operates on
    # @param context [any]
    def initialize(query:, params:, config:, resource_name: query.model.to_s, context: {})
      @query = query
      @params = params
      @config = config
      @resource_name = resource_name
      @context = context
    end

    def call
      return query if params.blank?

      params.reduce(query) do |reduced_query, (functor_key, functor_value)|
        functor_instance(functor_key, reduced_query, functor_value).call
      end
    end

    private

    attr_reader :query, :params, :config, :resource_name, :context

    def functor_instance(functor_key, reduced_query, functor_value)
      functor_group_name = config.functor_group.to_s.capitalize
      functor_name = functor_key.classify

      klass = functor_class(functor_key, reduced_query, functor_value)

      return klass.new(reduced_query, functor_value, context) if klass

      ::Qreds::CatchAllFunctor.new(
        reduced_query,
        functor_value,
        context,
        functor_key,
        config
      )
    end

    def functor_class(functor_key, reduced_query, functor_value)
      functor_group_name = config.functor_group.to_s.capitalize
      functor_name = functor_key.classify

      klass = "::#{functor_group_name}::#{resource_name}::#{functor_name}".constantize
    rescue NameError
    end
  end
end
