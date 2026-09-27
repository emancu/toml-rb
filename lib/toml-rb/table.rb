module TomlRB
  class Table
    def initialize(dotted_keys)
      @dotted_keys = dotted_keys
    end

    def navigate_keys(hash, tables, symbolize_keys = false)
      current = hash
      keys = symbolize_keys ? @dotted_keys.map(&:to_sym) : @dotted_keys
      keys.each do |key|
        unless current.key?(key)
          current[key] = {}
          tables[current[key]] = :implicit
        end
        element = current[key]
        fail ValueOverwriteError.new(key) unless tables.key?(element)

        current = element.is_a?(Array) ? element.last : element
      end
      fail ValueOverwriteError.new(full_key) unless tables[current] == :implicit

      tables[current] = :explicit
      current
    end

    def accept_visitor(parser)
      parser.visit_table self
    end

    def full_key
      @dotted_keys.join(".")
    end
  end
end
