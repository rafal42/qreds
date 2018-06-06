module Filters
  module MockModel
    class Equality
      def initialize(collection, value)
        @collection = collection
        @value = value
      end

      def call
        @collection.select { |el| el == @value }
      end
    end
  end

  module DifferentMockModel
    class Equality
      def initialize(collection, value)
        @collection = collection
        @value = value
      end

      def call
        @collection.select { |el| el != @value }
      end
    end
  end
end
