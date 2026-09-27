module TomlRB
  class Parser
    attr_reader :hash

    def initialize(content, symbolize_keys: false)
      @hash = {}
      # Tables and arrays of tables that headers or dotted keys made, by identity:
      # :implicit (super-table of a header), :explicit (header) or :dotted (dotted key).
      # Inline tables and static arrays are absent, so no header or dotted key can enter them.
      @tables = {}.compare_by_identity
      @current = @hash
      @symbolize_keys = symbolize_keys

      begin
        parsed = TomlRB::Document.parse(content)
        parsed.matches.map(&:value).compact.each { |m| m.accept_visitor(self) }
      rescue Citrus::ParseError => e
        raise TomlRB::ParseError.new(e.message)
      rescue Encoding::CompatibilityError => e
        raise TomlRB::ParseError.new("Encoding error: #{e.message}")
      rescue ArgumentError => e
        if e.message.include?("invalid byte sequence") || e.message.include?("encoding")
          raise TomlRB::ParseError.new("Encoding error: #{e.message}")
        else
          raise
        end
      end
    end

    # Read about the Visitor pattern
    # http://en.wikipedia.org/wiki/Visitor_pattern
    def visit_table_array(table_array)
      @current = table_array.navigate_keys @hash, @tables, @symbolize_keys
    end

    def visit_table(table)
      @current = table.navigate_keys @hash, @tables, @symbolize_keys
    end

    def visit_keyvalue(keyvalue)
      keyvalue.assign @current, @tables, @symbolize_keys
    end
  end
end
