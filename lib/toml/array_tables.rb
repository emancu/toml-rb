module TOML
  class ArrayTables
    def initialize(nested_keys)
      @nested_keys = nested_keys
    end

    def navigate_keys(hash, symbolize_keys = false)
      @nested_keys.each do |key|
        key = symbolize_keys ? key.to_sym : key
        hash[key] = [] unless hash[key]
        hash[key] << {} if @nested_keys.last == key.to_s
        hash = hash[key].last
      end

      hash
    end

    def accept_visitor(parser)
      parser.visit_array_tables self
    end
  end
end

# Used in document.citrus
module ArrayTables
  def value
    TOML::ArrayTables.new(captures[:key].map(&:value))
  end
end

