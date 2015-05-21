module TOML
  # Used in primitive.citrus
  module BasicString
    def value
      aux = TOML::BasicString.transform_escaped_chars first.value

      aux[1...-1]
    end

    def self.transform_escaped_chars(str)
      str
          .gsub(/\\0/, "\0")
          .gsub(/\\t/, "\t")
          .gsub(/\\n/, "\n")
          .gsub(/\\\"/, '"')
          .gsub(/\\r/, "\r")
          .gsub(/\\\\/, '\\')
    end
  end

  module LiteralString
    def value
      first.value[1...-1]
    end
  end

  module MultilineString
    def value
      aux = captures[:text].first.value

      # Remove spaces on multilined Singleline strings
      aux.gsub!(/\\\r?\n[\n\t\r ]*/, '')

      TOML::BasicString.transform_escaped_chars aux
    end
  end

  module MultilineLiteral
    def value
      aux = captures[:text].first.value

      aux.gsub(/\\\r?\n[\n\t\r ]*/, '')
    end
  end

end