module TomlRB
  class Table
    def initialize(dotted_keys)
      @dotted_keys = dotted_keys
    end

    def navigate_keys(hash, visited_keys, symbolize_keys = false)
      ensure_key_not_defined(visited_keys)
      current = hash
      keys = symbolize_keys ? @dotted_keys.map(&:to_sym) : @dotted_keys
      keys.each_with_index do |key, index|
        current[key] = {} unless current.key?(key)
        element = current[key]

        # If this is the final key and it's already an array (from [[key]]), that's invalid
        is_final_key = (index == keys.length - 1)
        if is_final_key && element.is_a?(Array)
          fail ValueOverwriteError.new(key)
        end

        current = element.is_a?(Array) ? element.last : element
        # check that key has not been defined before as a scalar value
        fail ValueOverwriteError.new(key) unless current.is_a?(Hash)
      end
      current
    end

    def accept_visitor(parser)
      parser.visit_table self
    end

    def full_key
      @dotted_keys.join(".")
    end

    private

    # Fail if the key was already defined with a ValueOverwriteError
    def ensure_key_not_defined(visited_keys)
      fail ValueOverwriteError.new(full_key) if visited_keys.include?(full_key)
      visited_keys << full_key
    end
  end

  # Used in document.citrus
  module TableParser
    def value
      TomlRB::Table.new(captures[:stripped_key].map(&:value).first)
    end
  end
end
