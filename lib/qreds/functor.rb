module Qreds
  class Functor
    def initialize(query, value, context={})
      @query = query
      @value = value
      @context = context
    end

    private

    attr_reader :query, :value, :context
  end
end
