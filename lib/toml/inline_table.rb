module InlineTable
  def value
    keyvalue_pairs = captures[:keyvalue].map(&:value)

    Hash[keyvalue_pairs.map { |kv| [kv.key, kv.value] }]
  end
end

module InlineTableArray
  def value
    tables = []
    tables = captures[:hash_array].map{ |x| x.captures[:inline_table] }

    tables.flatten.map(&:value)
  end
end
