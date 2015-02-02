module TOML
  class TableArray
    def initialize(nested_keys)
      @nested_keys = nested_keys
    end

    def navigate_keys(hash, symbolize_keys = false)
      @nested_keys.each do |key|
        key = symbolize_keys ? key.to_sym : key
        hash[key] = [] unless hash[key]
        hash[key] << {} if @nested_keys.last == key.to_s || hash[key].empty?
        hash = hash[key].is_a?(Array) ? hash[key].last : hash[key]
      end

      hash
    end

    def accept_visitor(parser)
      parser.visit_table_array self
    end
  end
end

# Used in document.citrus
module TableArray
  def value
    TOML::TableArray.new(captures[:key].map(&:value))
  end
end
