require_relative "inline_table"

module TomlRB
  class Keyvalue
    attr_reader :dotted_keys, :value, :symbolize_keys

    def initialize(dotted_keys, value)
      @dotted_keys = dotted_keys
      @value = value
      @symbolize_keys = false
    end

    def assign(hash, fully_defined_keys, symbolize_keys = false)
      @symbolize_keys = symbolize_keys
      dotted_keys_str = @dotted_keys.join(".")
      keys = symbolize_keys ? @dotted_keys.map(&:to_sym) : @dotted_keys
      update = keys.reverse.inject(visit_value(@value)) { |k1, k2| {k2 => k1} }

      if @value.is_a?(InlineTable)
        # Inline tables are immutable - check if we're trying to add keys to an existing inline table
        if fully_defined_keys.find { |k| dotted_keys_str.start_with?("#{k}.") }
          fail ValueOverwriteError.new(@dotted_keys.first)
        end

        # Check if any existing keys start with this inline table key (dotted keys already defined)
        if fully_defined_keys.find { |k| k.start_with?("#{dotted_keys_str}.") }
          fail ValueOverwriteError.new(@dotted_keys.first)
        end

        # Check if the key already exists in the hash (was defined via dotted keys)
        if hash.dig(*keys).is_a?(Hash) && !hash.dig(*keys).empty?
          fail ValueOverwriteError.new(@dotted_keys.first)
        end

        fully_defined_keys << dotted_keys_str
        dotted_key_merge(hash, update)
      elsif fully_defined_keys.find { |k| dotted_keys_str.start_with?("#{k}.") }
        # Trying to add keys to an already defined inline table
        fail ValueOverwriteError.new(@dotted_keys.first)
      else
        dotted_key_merge(hash, update)
      end
    end

    def dotted_key_merge(hash, update)
      hash.merge!(update) do |key, old, new|
        if old.is_a?(Hash) && new.is_a?(Hash)
          dotted_key_merge(old, new)
        else
          fail ValueOverwriteError.new(key)
        end
      end
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
