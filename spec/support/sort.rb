module Sort
  module MockModel
    class Simple < ::Qreds::Functor
      def call
        query.sort_by { |el| value == 'asc' ? el : -el }
      end
    end
  end
end
