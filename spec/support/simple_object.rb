class SimpleObject
  def initialize(value)
    @value = value
  end

  def some_field
    @value
  end

  attr_reader :value
end
