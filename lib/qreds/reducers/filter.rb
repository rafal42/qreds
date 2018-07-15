require 'qreds/reducers/attribute'

module Qreds
  module Reducers
    module Filter
      def self.call(query, attr_name, value, operator, _)
        attribute = Qreds::Reducers::Attribute.new(attr_name)

        q = if operator.count('?') > 1
          query.where("#{attribute.sendable_name} #{operator}", *value)
        else
          query.where("#{attribute.sendable_name} #{operator}", value)
        end

        attribute.apply_joins(q)
      end

      def self.operator_mapping
        {
          'lt' => '< ?',
          'lte' => '<= ?',
          'eq' => '= ?',
          'gt' => '> ?',
          'gte' => '>= ?',
          'in' => 'IN (?)',
          'btw' => 'BETWEEN ? AND ?'
        }
      end

      def self.functor_group
        'filters'
      end
    end
  end
end
