module TomlRB
  class Keyvalue
    attr_reader :dotted_keys, :value, :symbolize_keys

    def initialize(dotted_keys, value)
      @dotted_keys = dotted_keys
      @value = value
      @symbolize_keys = false
    end

    def assign(hash, symbolize_keys = false)
      @symbolize_keys = symbolize_keys
      @dotted_keys = symbolize_keys ? @dotted_keys.map(&:to_sym) : @dotted_keys
      update = @dotted_keys.reverse.inject(visit_value @value) { |k1, k2| { k2 => k1 } }
      hash.merge!(update) { |key, _, _| fail ValueOverwriteError.new(key) }
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
      TomlRB::Keyvalue.new(capture(:stripped_key).value, capture(:v).value)
    end
  end
end
