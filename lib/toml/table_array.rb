module TOML
  class TableArray
    def initialize(nested_keys)
      @nested_keys = nested_keys
    end

    def navigate_keys(hash, symbolize_keys = false)
      last_key = @nested_keys.pop

      # Go over the parent keys
      @nested_keys.each do |key|
        key = symbolize_keys ? key.to_sym : key
        hash[key] = {} unless hash[key]

        if hash[key].is_a? Array
          hash[key] << {} if hash[key].empty?
          hash = hash[key].last
        else
          hash = hash[key]
        end
      end

      # Define Table Array
      hash[last_key] = [] unless hash[last_key]
      hash[last_key] << {}

      hash[last_key].last
    end

    def accept_visitor(parser)
      parser.visit_table_array self
    end
  end

  # Used in document.citrus
  module TableArrayParser
    def value
      TOML::TableArray.new(captures[:key].map(&:value))
    end
  end
end
