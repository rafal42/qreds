module TestBetweenInteger
  def test_between_integer(left, right)
    self >= left && self <= right
  end
end

class Fixnum
  include TestBetweenInteger
end

class Integer
  include TestBetweenInteger
end

class MockCollection < Array
  def model
    MockModel
  end

  def where(arg, *values)
    if values.nil?
      handle_where_hash(arg)
    else
      handle_where_string(arg, *values)
    end
  end

  def order(hash)
    k, v = key_val(hash)

    sort_by do |el|
      sort_val = el.public_send(k)
      v == 'asc' ? sort_val : -sort_val
    end
  end

  private

  def handle_where_hash(hash)
    k, v = key_val(main_arg)

    select { |el| el.public_send(k) == v }
  end

  def handle_where_string(attr_name_with_operator, *values)
    attr_name, _, operator = attr_name_with_operator.partition(' ')

    select { |el| el.public_send(attr_name).public_send(sanitize_operator(operator), *values) }
  end

  def sanitize_operator(operator)
    return :== if operator == '= ?'
    return :test_between_integer if operator == 'BETWEEN ? AND ?'
    operator
  end

  def key_val(hash)
    k = hash.keys.first
    v = hash[k]

    [k, v]
  end
end
