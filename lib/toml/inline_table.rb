module InlineTable
  def value
    keyvalue_pairs = captures[:keyvalue].map(&:value)

    keyvalue_pairs.map { |kv| [kv.key, kv.value] }.to_h
  end
end
