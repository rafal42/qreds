module Qreds
  class Reducer
    # @param query [any] the initial value to be provided to reduce()
    # @param params [Hash] with keys being functor names and values the functor arguments.
    # @param config [Config] to determine functor group and to pass on to the CatchAllFunctor
    # @param resource_name [String] the name of the resource that query operates on
    def initialize(query:, params:, config:, resource_name: query.model.to_s)
      @query = query
      @params = params
      @config = config
      @resource_name = resource_name
    end

    def call
      return query if params.blank?

      params.reduce(query) do |reduced_query, (functor_key, functor_value)|
        functor_instance(functor_key, reduced_query, functor_value).call
      end
    end

    private

    attr_reader :query, :params, :config, :resource_name

    def functor_instance(functor_key, reduced_query, functor_value)
      functor_group_name = config.functor_group.to_s.capitalize
      functor_name = functor_key.classify

      klass = "::#{functor_group_name}::#{resource_name}::#{functor_name}".constantize
      klass.new(reduced_query, functor_value)
    rescue NameError
      ::Qreds::CatchAllFunctor.new(
        reduced_query,
        functor_key,
        functor_value,
        config
      )
    end
  end
end
