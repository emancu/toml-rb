module TomlRB
  class TableArray
    def initialize(dotted_keys)
      @dotted_keys = dotted_keys
    end

    def navigate_keys(hash, tables, symbolize_keys = false)
      current = hash
      *keys, last_key = symbolize_keys ? @dotted_keys.map(&:to_sym) : @dotted_keys

      # Go over the parent keys
      keys.each do |key|
        unless current.key?(key)
          current[key] = {}
          tables[current[key]] = :implicit
        end
        element = current[key]
        fail ValueOverwriteError.new(key) unless tables.key?(element)

        current = element.is_a?(Array) ? element.last : element
      end

      # Define Table Array
      if current[last_key].is_a? Hash
        fail TomlRB::ParseError,
          "#{last_key} was defined as hash but is now redefined as a table!"
      end
      unless current.key?(last_key)
        current[last_key] = []
        tables[current[last_key]] = :explicit
      end
      fail ValueOverwriteError.new(last_key) unless tables.key?(current[last_key])

      current[last_key] << {}
      tables[current[last_key].last] = :explicit
      current[last_key].last
    end

    def accept_visitor(parser)
      parser.visit_table_array self
    end
  end

  # Used in document.citrus
  module TableArrayParser
    def value
      TomlRB::TableArray.new(captures[:stripped_key].map(&:value).first)
    end
  end
end
