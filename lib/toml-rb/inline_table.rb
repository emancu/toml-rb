module TomlRB
  class InlineTable
    def initialize(keyvalue_pairs)
      @pairs = keyvalue_pairs
    end

    def accept_visitor(keyvalue)
      value keyvalue.symbolize_keys
    end

    def value(symbolize_keys = false)
      result = {}
      tables = {}.compare_by_identity
      @pairs.each { |kv| kv.assign(result, tables, symbolize_keys) }
      result
    end
  end

  module InlineTableParser
    def value
      TomlRB::InlineTable.new(captures[:keyvalue].map(&:value))
    end
  end
end
