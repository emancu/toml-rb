module TOML
  class ParseError < StandardError; end

  class Parser
    attr_reader :hash

    def initialize(content, options = {})
      @hash = {}
      @current = @hash
      @symbolize_keys = options[:symbolize_keys]

      begin
        parsed = Document.parse(content)
        parsed.matches.map(&:value).compact.each { |m| m.accept_visitor(self) }
      rescue Citrus::ParseError => e
        raise ParseError.new(e.message)
      end
    end

    # Read about the Visitor pattern
    # http://en.wikipedia.org/wiki/Visitor_pattern
    def visit_array_tables(array_tables)
      @current = array_tables.navigate_keys @hash, @symbolize_keys
    end

    def visit_keygroup(keygroup)
      @current = keygroup.navigate_keys(@hash, @symbolize_keys)
    end

    def visit_keyvalue(keyvalue)
      keyvalue.assign(@current, @symbolize_keys)
    end
  end
end
