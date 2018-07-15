module Qreds
  module Reducers
    class Attribute
      # @param attr_name name of the attribute
      # @example value
      # @example association_name.value
      # @example association_name.another_association_name.value
      def initialize(attr_name)
        @attr_name = attr_name
      end

      # If attr name has dots, returns last two parts.
      # If it does not, returns the whole string.
      # @return [String]
      def sendable_name
        terms.last(2).join('.')
      end

      # Applies joins based on the attr_name and group(:id) to the passed query
      # @param query
      def apply_joins(query)
        return query if terms.size == 1

        joins_terms = terms[0..-2].reverse.reduce({}) { |hash, term| { term => hash } }
        query.joins(joins_terms).group(:id)
      end

      private

      attr_reader :attr_name

      def terms
        @terms ||= attr_name.split('.')
      end
    end
  end
end
