module GrapeReducers
  class CatchAllFunctor < Functor
    def initialize(collection, key, value, method_name)
      super(collection, value)

      @key = key
      @method_name = method_name
    end

    def call
      collection.public_send(method_name, key => value)
    end

    private

    attr_reader :key, :method_name
  end
end
