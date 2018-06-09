module GrapeReducers
  class Config
    attr_accessor :functor_group, :default_lambda, :operator_mapping

    @reducers = {}

    def initialize(args)
      args.each do |(key, value)|
        send("#{key}=", value)
      end
    end

    class << self
      delegate :[], to: :@reducers

      # @param helper_name [Symbol|String]
      # @yield reducer [Hash]
      def define_reducer(helper_name)
        reducer = new(functor_group: helper_name)

        yield reducer

        @reducers[helper_name] = reducer
      end
    end

    OPERATOR_MAPPING_COMP_PGSQL = {
      'lt' => '< ?',
      'lte' => '<= ?',
      'eq' => '= ?',
      'gt' => '> ?',
      'gte' => '>= ?',
      'in' => 'IN ?',
      'btw' => 'BETWEEN ? AND ?'
    }

    private_constant :OPERATOR_MAPPING_COMP_PGSQL

    define_reducer :sort do |reducer|
      reducer.default_lambda = ->(reducible, attr_name, value, _) do
        reducible.order(attr_name => value)
      end
    end

    define_reducer :filter do |reducer|
      reducer.default_lambda = ->(reducible, attr_name, value, operator) do
        reducible.where("#{attr_name} #{operator}", value)
      end
      reducer.operator_mapping = OPERATOR_MAPPING_COMP_PGSQL
      reducer.functor_group = 'filters'
    end
  end
end
