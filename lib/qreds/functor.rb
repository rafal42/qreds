module Qreds
  class Functor
    def initialize(query, value)
      @query = query
      @value = value
    end

    private

    attr_reader :query, :value
  end
end
