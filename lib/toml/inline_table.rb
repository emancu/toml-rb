module InlineTable
  def value
    keyvalue_pairs = captures[:keyvalue].map(&:value)

    Hash[keyvalue_pairs.map { |kv| [kv.key, kv.value] }]
  end
end
