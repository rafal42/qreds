module GrapeReducers
  class CatchAllFunctor < Functor
    def initialize(collection, key, value, config)
      super(collection, value)

      @key = key
      @config = config
    end

    def call
      head, _, tail = key.rpartition('_')
      operator = map_operator(tail)
      attr_name = operator.nil? ? key : head

      config.default_lambda.call(collection, attr_name, value, operator)
    end

    private

    attr_reader :key, :config

    def map_operator(operator)
      return nil if config.operator_mapping.nil?
      mapped = config.operator_mapping[operator]

      raise "No operator mapping found for #{operator}" if mapped.nil?

      mapped
    end
  end
end
