require 'qreds/endpoint'
require 'qreds/reducers/filter'
require 'qreds/reducers/sort'

module Qreds
  class Config
    attr_accessor :functor_group, :default_lambda, :operator_mapping

    @reducers = {}

    def self.reducers
      @reducers
    end

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

    define_reducer :sort do |reducer|
      reducer.default_lambda = Qreds::Reducers::Sort.method(:call)
    end

    define_reducer :filter do |reducer|
      reducer.default_lambda = Qreds::Reducers::Filter.method(:call)
      reducer.operator_mapping = Qreds::Reducers::Filter.operator_mapping
      reducer.functor_group = Qreds::Reducers::Filter.functor_group
    end
  end
end
