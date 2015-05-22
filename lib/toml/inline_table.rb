module TOML
  class InlineTable
    attr_reader :symbolize_keys

    def initialize(keyvalue_pairs)
      @pairs = keyvalue_pairs
      @symbolize_keys = false
    end

    def value(symbolize_keys = false)
      if (@symbolize_keys = symbolize_keys)
        tuple = ->(kv) { [kv.key.to_sym, visit_value(kv.value)] }
      else
        tuple = ->(kv) { [kv.key, visit_value(kv.value)] }
      end

      Hash[@pairs.map(&tuple)]
    end

    def visit_inline_table(inline_table)
      result = {}

      inline_table.value(@symbolize_keys).each do |k, v|
        result[key k] = visit_value v
      end

      result
    end

    def accept_visitor(keyvalue)
      keyvalue.visit_inline_table self
    end

    private

    def visit_value(a_value)
      return a_value unless a_value.respond_to? :accept_visitor

      a_value.accept_visitor self
    end

    def key(a_key)
      symbolize_keys ? a_key.to_sym : a_key
    end
  end

  class InlineTableArray
    def initialize(inline_tables)
      @inline_tables = inline_tables
    end

    def value(symbolize_keys = false)
      @inline_tables.map { |it| it.value(symbolize_keys) }
    end
  end

  module InlineTableParser
    def value
      TOML::InlineTable.new captures[:keyvalue].map(&:value)
    end
  end

  module InlineTableArrayParser
    def value
      tables = captures[:inline_table_array_elements].map do |x|
        x.captures[:inline_table]
      end

      TOML::InlineTableArray.new(tables.flatten.map(&:value)).value
    end
  end
end
