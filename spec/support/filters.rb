module Filters
  module MockModel
    class Equality < ::Qreds::Functor
      def call
        query.where('equality' => value)
      end
    end
  end

  module DifferentMockModel
    class Equality < ::Qreds::Functor
      def call
        query.where('equality != ?', value)
      end
    end
  end
end
