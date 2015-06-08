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
      str.gsub(/([^\\](?:\\\\)*\\u[\da-f]{4})/i) do |m|
        m[0...-6] + [m[-4..-1].to_i(16)].pack('U')
      end
    end

    # Replace special characters such as line feed and tabs.
    def self.decode_special_char(str)
      str.gsub(/\\0/, "\0")
        .gsub(/\\t/, "\t")
        .gsub(/\\b/, "\b")
        .gsub(/\\f/, "\f")
        .gsub(/\\n/, "\n")
        .gsub(/\\\"/, '"')
        .gsub(/\\r/, "\r")
    end

    def self.transform_escaped_chars(str)
      str = decode_special_char(str)
      str = decode_unicode(str)
      str.gsub(/\\\\/, '\\').encode('utf-8')
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
