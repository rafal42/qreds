class MockQuery
  def initialize
    @where_values = {}
    @order_values = {}
    @joins_values = []
    @group_values = []
  end

  def model
    MockModel
  end

  attr_reader :where_values, :order_values, :joins_values, :group_values

  def explain
    {
      where: where_values,
      order: order_values,
      joins: joins_values,
      group: group_values
    }
  end

  def where(*args)
    if args.count == 1
      where_values.merge!(args.first)
      return self
    end

    attr_name_with_operator, *values = args
    attr_name, _, operator = attr_name_with_operator.partition(' ')

    where_values["#{attr_name} #{operator}"] = values

    self
  end

  def order(arg)
    k, v = arg.first
    order_values[k] = v

    self
  end

  def joins(*values)
    values.each(&joins_values.method(:push))

    self
  end

  def group(*values)
    values.each(&group_values.method(:push))

    self
  end
end
