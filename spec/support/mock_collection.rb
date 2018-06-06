class MockCollection < Array
  def model
    MockModel
  end

  def where(hash)
    k, v = key_val(hash)

    select { |el| el.public_send(k) == v }
  end

  def order(hash)
    k, v = key_val(hash)

    sort_by do |el|
      sort_val = el.public_send(k)
      v == 'asc' ? sort_val : -sort_val
    end
  end

  private

  def key_val(hash)
    k = hash.keys.first
    v = hash[k]

    [k, v]
  end
end
