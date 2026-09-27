module TomlRB
  # Used in primitive.citrus
  module BasicString
    SPECIAL_CHARS = {
      "\\t" => "\t",
      "\\b" => "\b",
      "\\e" => "\e",
      "\\f" => "\f",
      "\\n" => "\n",
      "\\r" => "\r",
      '\\"' => '"',
      "\\\\" => "\\"
    }.freeze

    def value
      aux = TomlRB::BasicString.transform_escaped_chars first.value

      aux[1...-1]
    end

    # Replace the unicode escaped characters with the corresponding character
    # e.g. \u03B4 => ?
    def self.decode_unicode(str)
      code = str[2..-1].to_i(16)
      if code.between?(0xD800, 0xDFFF) || code > 0x10FFFF
        fail ParseError.new "Escape sequence #{str} is not a Unicode scalar value"
      end

      [code].pack("U")
    end

    def self.transform_escaped_chars(str)
      str.gsub(/\\(x[\da-fA-F]{2}|u[\da-fA-F]{4}|U[\da-fA-F]{8}|[ \t]*\r?\n[ \t\r\n]*|.)/) do |m|
        if m.include?("\n")
          ""
        elsif m.size == 2
          SPECIAL_CHARS[m] || parse_error(m)
        else
          decode_unicode(m).force_encoding("UTF-8")
        end
      end
    end

    def self.parse_error(m)
      fail ParseError.new "Escape sequence #{m} is reserved"
    end
  end

  module LiteralString
    def value
      first.value[1...-1]
    end
  end

  module MultilineString
    def value
      TomlRB::BasicString.transform_escaped_chars captures[:text].first.value
    end
  end

  module MultilineLiteral
    def value
      captures[:text].first.value
    end
  end
end
