module TOML
  class Keyvalue
    attr_reader :value, :symbolize_keys

    def initialize(key, value)
      @key = key
      @value = value
      @symbolize_keys = false
    end

    def assign(hash, symbolize_keys = false)
      @symbolize_keys = symbolize_keys
      fail ValueOverwriteError.new(key) if hash.key?(key)
      hash[key] = visit_value @value
    end

    def visit_inline_table(inline_table)
      result = {}

      inline_table.value(@symbolize_keys).each do |k, v|
        result[key k] = visit_value v
      end

      result
    end

    def key(a_key = @key)
      symbolize_keys ? a_key.to_sym : a_key
    end

    def accept_visitor(parser)
      parser.visit_keyvalue self
    end

    private

    def visit_value(a_value)
      return a_value unless a_value.respond_to? :accept_visitor

      a_value.accept_visitor self
    end
  end
  # Used in document.citrus
  module KeyvalueParser
    def value
      TOML::Keyvalue.new(capture(:stripped_key).value, capture(:v).value)
    end
  end
end
