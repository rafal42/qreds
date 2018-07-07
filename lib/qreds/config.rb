require 'qreds/endpoint'

module Qreds
  class Config
    attr_accessor :functor_group, :default_lambda, :operator_mapping

    @reducers = {}

    # @param args [Hash<#to_s, any>]
    def initialize(args)
      args.each do |(key, value)|
        send("#{key}=", value)
      end
    end

    class << self
      delegate :[], to: :@reducers

      # @param helper_name [Symbol|String] the name of the helper method to be defined
      # @yield config [Hash]
      def define_reducer(helper_name, strategy: method(:define_endpoint_method))
        config = new(functor_group: helper_name)

        yield config

        strategy.call(helper_name, config)
      end

      private

      def define_endpoint_method(helper_name, config)
        ::Qreds::Endpoint.send(:define_method, helper_name) do |query, context={}, **args|
          functor_group = config.functor_group

          declared_params = declared(params, include_missing: false)[functor_group]

          ::Qreds::Reducer.new(
            query: query,
            params: declared_params,
            config: config,
            context: context,
            **args
          ).call
        end

        @reducers[helper_name] = config
      end
    end

    OPERATOR_MAPPING_COMP_PGSQL = {
      'lt' => '< ?',
      'lte' => '<= ?',
      'eq' => '= ?',
      'gt' => '> ?',
      'gte' => '>= ?',
      'in' => 'IN (?)',
      'btw' => 'BETWEEN ? AND ?'
    }

    private_constant :OPERATOR_MAPPING_COMP_PGSQL

    define_reducer :sort do |reducer|
      reducer.default_lambda = ->(query, attr_name, value, _, _) do
        query.order(attr_name => value)
      end
    end

    define_reducer :filter do |reducer|
      reducer.default_lambda = ->(query, attr_name, value, operator, _) do
        if operator.count('?') > 1
          query.where("#{attr_name} #{operator}", *value)
        else
          query.where("#{attr_name} #{operator}", value)
        end
      end
      reducer.operator_mapping = OPERATOR_MAPPING_COMP_PGSQL
      reducer.functor_group = 'filters'
    end
  end
end
