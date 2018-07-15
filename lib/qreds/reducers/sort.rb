require 'qreds/reducers/attribute'

module Qreds
  module Reducers
    module Sort
      def self.call(query, attr_name, value, _, _)
        attribute = Qreds::Reducers::Attribute.new(attr_name)

        attribute.apply_joins(
          query.order(attribute.sendable_name => value)
        )
      end
    end
  end
end
