module TOML
  # Used in primitive.citrus
  module BasicString
    def value
      aux = TOML::BasicString.transform_escaped_chars first.value

      aux[1...-1]
    end

    # Replace the unicode escaped characters with the corresponding character
    # e.g. \u03B4 => ?
    def self.decode_unicode(str)
      str.gsub(/\\u([\da-f]{4,6})/i) do |m|
        [m[2..-1].to_i(16)].pack('U')
      end
    end

    # Replace special characters such as line feed and tabs.
    def self.decode_special_char(str)
      str.gsub(/\\+(\"|.)/) do |m|
        backslashes = "\\" * ((m.size - 1) / 2)

        if m.size.even?
          sequence = m[-2..-1]
          sc = special_chars[sequence]

          fail EscapeSequenceReserved.new(sequence) unless sc

          backslashes + sc
        else
          backslashes + m[-1]
        end
      end
    end

    def self.transform_escaped_chars(str)
      str = decode_unicode(str)
      str = decode_special_char(str)
      str.encode('utf-8')
    end

    def self.special_chars
      @special_chars ||= {
        '\\0' => "\0",
        '\\t' => "\t",
        '\\b' => "\b",
        '\\f' => "\f",
        '\\n' => "\n",
        '\\r' => "\r",
        '\\"' => '"'
      }
    end
  end

  module LiteralString
    def value
      first.value[1...-1]
    end
  end

  module MultilineString
    def value
      return '' if captures[:text].empty?
      aux = captures[:text].first.value

      # Remove spaces on multilined Singleline strings
      aux.gsub!(/\\\r?\n[\n\t\r ]*/, '')

      TOML::BasicString.transform_escaped_chars aux
    end
  end

  module MultilineLiteral
    def value
      return '' if captures[:text].empty?
      aux = captures[:text].first.value

      aux.gsub(/\\\r?\n[\n\t\r ]*/, '')
    end
  end
end
