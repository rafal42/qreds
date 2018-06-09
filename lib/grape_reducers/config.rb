module GrapeReducers
  class Config
    @reducers = {}

    class << self
      delegate :[], to: :@reducers

      def define_reducer(helper_name:, default_lambda:, operator_mapping: nil, params_group_name: helper_name)
        @reducers[helper_name] = {
          default_lambda: default_lambda,
          operator_mapping: operator_mapping,
          params_group_name: params_group_name
        }
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

    define_reducer(
      helper_name: :sort,
      default_lambda: ->(reducible, attr_name, value, _) do
        reducible.order(attr_name => value)
      end
    )

    define_reducer(
      helper_name: :filter,
      default_lambda: ->(reducible, attr_name, value, operator) do
        reducible.where("#{attr_name} #{operator}", value)
      end,
      operator_mapping: OPERATOR_MAPPING_COMP_PGSQL,
      params_group_name: 'filters'
    )
  end
end
