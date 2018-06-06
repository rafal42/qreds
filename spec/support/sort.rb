module Sort
  module MockModel
    class Simple
      def initialize(collection, value)
        @collection = collection
        @value = value
      end

      def call
        @collection.sort_by { |el| @value == 'asc' ? el : -el }
      end
    end
  end
end
