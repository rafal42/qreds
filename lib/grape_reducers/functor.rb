module GrapeReducers
  class Functor
    def initialize(collection, value)
      @collection = collection
      @value = value
    end

    private

    attr_reader :collection, :value
  end
end
