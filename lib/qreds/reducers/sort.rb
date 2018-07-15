require 'qreds/reducers/attribute'

module Qreds
  module Reducers
    module Sort
      def self.call(query, attr_name, value, _, _)
        query.order(attr_name => value)
      end
    end
  end
end
