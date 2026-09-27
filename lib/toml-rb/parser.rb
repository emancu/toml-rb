# frozen_string_literal: true

require "strscan"

module TomlRB
  class Parser
    BASIC_STRING = /(?:[^"\\\x00-\x08\x0a-\x1f\x7f]|\\.)*/
    LITERAL_STRING = /[^'\x00-\x08\x0a-\x1f\x7f]*/
    MULTILINE_STRING = /(?:[^"\\\x00-\x08\x0b-\x1f\x7f]|\r\n|\\(?:[^\r]|\r\n)|"{1,2}(?!"))*(?:"{0,2}(?="""))?/
    MULTILINE_LITERAL = /(?:[^'\x00-\x08\x0b-\x1f\x7f]|\r\n|'{1,2}(?!'))*(?:'{0,2}(?='''))?/
    # A UTF-8 regexp raises Encoding::CompatibilityError on binary input with high bytes.
    COMMENT = /[^\x00-\x08\x0a-\x1f\x7f]*/u
    DATETIME = /(\d{4})-(\d\d)-(\d\d)(?:[Tt ]([0-2]\d):([0-6]\d)(?::([0-6]\d)(?:\.(\d{1,9})\d*)?)?([Zz]|[+-]\d\d:\d\d)?)?/
    TIME = /([0-2]\d):([0-6]\d)(?::([0-6]\d)(?:\.(\d{1,9})\d*)?)?/
    PREFIXED_INTEGER = /0x[0-9a-fA-F](?:_?[0-9a-fA-F])*|0o[0-7](?:_?[0-7])*|0b[01](?:_?[01])*/
    DECIMAL = /[+-]?(?:0|[1-9](?:_?\d)*)(\.\d(?:_?\d)*(?:[eE][+-]?\d(?:_?\d)*)?|[eE][+-]?\d(?:_?\d)*)?/
    MAX_NESTING = 100

    attr_reader :hash

    def initialize(content, symbolize_keys: false)
      @hash = {}
      # Tables and arrays of tables that headers or dotted keys made, by identity:
      # :implicit (super-table of a header), :explicit (header) or :dotted (dotted key).
      # Inline tables and static arrays are absent, so no header or dotted key can enter them.
      @tables = {}.compare_by_identity
      @current = @hash
      @symbolize_keys = symbolize_keys
      @depth = 0

      begin
        @scanner = StringScanner.new(source_text(content))
        # The visitor runs after the whole document is parsed, so a syntax
        # error wins over a key or table that the visitor rejects.
        document.each { |statement| statement.accept_visitor(self) }
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

    private

    def source_text(source)
      if source.respond_to?(:to_path)
        File.read(source.to_path)
      elsif source.respond_to?(:read)
        source.read
      elsif source.respond_to?(:to_str)
        source.to_str
      else
        raise ArgumentError, "Unable to parse from #{source}"
      end
    end

    def document
      statements = []
      loop do
        @scanner.skip(/(?:[ \t]*\r?\n)*[ \t]*/)
        return statements if @scanner.eos?

        statements << statement unless @scanner.match?(/#/)
        line_end
      end
    end

    def statement
      if @scanner.match?(/\[/)
        @scanner.match?(/\[\[/) ? table_array : table
      else
        keyvalue
      end
    end

    def table_array
      @scanner.skip(/\[\[[ \t]*/)
      keys = key
      expect(/[ \t]*\]\]/, "']]'")
      TableArray.new(keys)
    end

    def table
      @scanner.skip(/\[[ \t]*/)
      keys = key
      expect(/[ \t]*\]/, "']'")
      Table.new(keys)
    end

    def keyvalue
      keys = key
      expect(/[ \t]*=[ \t]*/, "'='")
      Keyvalue.new(keys, value)
    end

    def key
      keys = [simple_key]
      keys << simple_key while @scanner.skip(/[ \t]*\.[ \t]*/)
      keys
    end

    def simple_key
      if (bare = @scanner.scan(/[A-Za-z0-9_-]+/))
        bare
      elsif @scanner.match?(/"/)
        basic_string
      elsif @scanner.match?(/'/)
        literal_string
      else
        syntax_error("a key")
      end
    end

    def value
      case @scanner.peek(1)
      when '"'
        @scanner.match?(/"""/) ? multiline_string : basic_string
      when "'"
        @scanner.match?(/'''/) ? multiline_literal : literal_string
      when "["
        nested { array }
      when "{"
        nested { inline_table }
      when "t"
        expect(/true/, "a value")
        true
      when "f"
        expect(/false/, "a value")
        false
      else
        datetime || local_time || number
      end
    end

    def basic_string
      @scanner.skip(/"/)
      text = @scanner.scan(BASIC_STRING)
      expect(/"/, %('"'))
      unescape(text)
    end

    def literal_string
      @scanner.skip(/'/)
      text = @scanner.scan(LITERAL_STRING)
      expect(/'/, %("'"))
      text
    end

    def multiline_string
      start = @scanner.pos
      @scanner.skip(/"""(?:\r?\n)?/)
      text = @scanner.scan(MULTILINE_STRING)
      @scanner.skip(/"""/) || syntax_error(%('"""' to close the string at #{location(start)}))
      unescape(text)
    end

    def multiline_literal
      start = @scanner.pos
      @scanner.skip(/'''(?:\r?\n)?/)
      text = @scanner.scan(MULTILINE_LITERAL)
      @scanner.skip(/'''/) || syntax_error(%("'''" to close the string at #{location(start)}))
      text
    end

    def unescape(text)
      text.include?("\\") ? BasicString.transform_escaped_chars(text) : text
    end

    def datetime
      return unless @scanner.skip(DATETIME)

      year, mon, day, hour, min, sec, sec_frac, offset = @scanner.values_at(1, 2, 3, 4, 5, 6, 7, 8)
      if hour.nil?
        DatetimeParser.local_date(year, mon, day)
      elsif offset
        DatetimeParser.offset_datetime(year, mon, day, hour, min, sec, sec_frac, offset)
      else
        DatetimeParser.local_datetime(year, mon, day, hour, min, sec, sec_frac)
      end
    end

    def local_time
      DatetimeParser.local_time(*@scanner.values_at(1, 2, 3, 4)) if @scanner.skip(TIME)
    end

    def number
      if (text = @scanner.scan(PREFIXED_INTEGER))
        Integer(text)
      elsif (text = @scanner.scan(DECIMAL))
        @scanner[1] ? text.to_f : text.to_i
      elsif (text = @scanner.scan(/[+-]?inf/))
        text.start_with?("-") ? -Float::INFINITY : Float::INFINITY
      elsif @scanner.skip(/[+-]?nan/)
        Float::NAN
      else
        syntax_error("a value")
      end
    end

    def array
      @scanner.skip(/\[/)
      values = []
      loop do
        skip_whitespace_and_comments
        return values if @scanner.skip(/\]/)

        values << value
        skip_whitespace_and_comments
        return values if @scanner.skip(/\]/)

        expect(/,/, "',' or ']'")
      end
    end

    def inline_table
      @scanner.skip(/\{/)
      pairs = []
      loop do
        skip_whitespace_and_comments
        return InlineTable.new(pairs) if @scanner.skip(/\}/)

        pairs << keyvalue
        skip_whitespace_and_comments
        return InlineTable.new(pairs) if @scanner.skip(/\}/)

        expect(/,/, "',' or '}'")
      end
    end

    # Each nested array or inline table recurses, so the limit stops a deep
    # document before it exhausts the stack.
    def nested
      @depth += 1
      syntax_error("at most #{MAX_NESTING} nested arrays and inline tables") if @depth > MAX_NESTING
      yield
    ensure
      @depth -= 1
    end

    def line_end
      return if @scanner.skip(/[ \t]*\r?\n/)

      @scanner.skip(/[ \t]*/)
      @scanner.skip(COMMENT) if @scanner.skip(/#/)
      new_line
    end

    def skip_whitespace_and_comments
      @scanner.skip(/[ \t\r\n]*/)
      while @scanner.skip(/#/)
        @scanner.skip(COMMENT)
        new_line
        @scanner.skip(/[ \t\r\n]*/)
      end
    end

    def new_line
      @scanner.skip(/\r?\n/) || @scanner.eos? || syntax_error("a new line")
    end

    def expect(pattern, expected)
      @scanner.skip(pattern) || syntax_error(expected)
    end

    def syntax_error(expected)
      @scanner.skip(/[ \t]*/)
      found = @scanner.eos? ? "end of input" : @scanner.check(/./m).inspect
      raise ParseError, "Unexpected #{found} at #{location(@scanner.pos)}: expected #{expected}"
    end

    def location(pos)
      consumed = @scanner.string.byteslice(0, pos)
      line = consumed.count("\n") + 1
      column = consumed.length - (consumed.rindex("\n") || -1)
      "line #{line}, column #{column}"
    end
  end
end
