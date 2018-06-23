module Filters
  module MockModel
    class Equality < ::Qreds::Functor
      def call
        query.select { |el| el == value }
      end
    end
  end

  module DifferentMockModel
    class Equality < ::Qreds::Functor
      def call
        query.select { |el| el != value }
      end
    end
  end
end
