class MockCollection < Array
  def model
    MockModel
  end

  def where(*args)
    if args.size == 1
      k, v = key_val(*args)

      select { |el| el.public_send(k) == v }
    else
      attr_name_with_operator, value = *args
      attr_name, operator = attr_name_with_operator.split(' ')[0..1]

      select { |el| el.public_send(attr_name).public_send(sanitize_operator(operator), value) }
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

  def sanitize_operator(operator)
    return '==' if operator == '='
    operator
  end

  def key_val(hash)
    k = hash.keys.first
    v = hash[k]

    [k, v]
  end
end
