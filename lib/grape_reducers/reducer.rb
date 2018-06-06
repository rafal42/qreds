module GrapeReducers
  class Reducer
    # @param functor_group [String] functor_group of reducable type (eg. Filters)
    # @param collection [any] the initial value to be provided to reduce()
    # @param reducible [Hash] with keys being functor names and values the functor arguments.
    # @param fallback_method [Symbol|String] used on collection when functor cannot be found
    # @param resource_name [String] the name of the resource that collection contains
    def initialize(functor_group:, collection:, reducible:, fallback_method:,
      resource_name: collection.model.to_s)
      @functor_group = functor_group
      @collection = collection
      @reducible = reducible
      @fallback_method = fallback_method
      @resource_name = resource_name
    end

    def call
      return collection if reducible.blank?

      reducible.reduce(collection) do |reduced_collection, (functor_key, functor_value)|
        functor_instance(functor_key, reduced_collection, functor_value).call
      end
    end

    private

    attr_reader :functor_group, :collection, :reducible, :fallback_method, :resource_name

    def functor_instance(functor_key, reduced_collection, functor_value)
      functor_group_name = functor_group.to_s.capitalize
      functor_name = functor_key.classify

      klass = "::#{functor_group_name}::#{resource_name}::#{functor_name}".constantize
      klass.new(reduced_collection, functor_value)
    rescue NameError
      ::GrapeReducers::CatchAllFunctor.new(
        reduced_collection,
        functor_key,
        functor_value,
        fallback_method
      )
    end
  end
end
