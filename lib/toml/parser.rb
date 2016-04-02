module TOML
  class Parser
    attr_reader :hash

    def initialize(content, options = {})
      @hash = {}
      @visited_keys = []
      @current = @hash
      @symbolize_keys = options[:symbolize_keys]

      begin
        parsed = TOML::Document.parse(content)
        parsed.matches.map(&:value).compact.each { |m| m.accept_visitor(self) }
      rescue Citrus::ParseError => e
        raise TOML::ParseError.new(e.message)
      end
    end

    # Read about the Visitor pattern
    # http://en.wikipedia.org/wiki/Visitor_pattern
    def visit_table_array(table_array)
      table_array_key = table_array.full_key
      @visited_keys.reject! { |k| k.start_with? table_array_key }

      @current = table_array.navigate_keys @hash, @symbolize_keys
    end

    def visit_keygroup(keygroup)
      @current = keygroup.navigate_keys @hash, @visited_keys, @symbolize_keys
    end

    def visit_keyvalue(keyvalue)
      keyvalue.assign @current, @symbolize_keys
    end
  end
end
