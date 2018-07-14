module Sort
  module MockModel
    class Simple < ::Qreds::Functor
      def call
        query.order('simple' => value)
      end
    end
  end
end
