module Qreds
  class Functor
    # @param query [any] the query to adjust
    # @param value [any] the parameter value
    # @param context [any]
    def initialize(query, value, context={})
      @query = query
      @value = value
      @context = context
    end

    private

    attr_reader :query, :value, :context
  end
end
