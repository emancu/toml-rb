# Used in primitive.citrus
module TomlBasicString
  def value
    aux = TomlBasicString.transform_escaped_chars first.value

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

module TomlLiteralString
  def value
    first.value[1...-1]
  end
end

module TomlMultilineString
  def value
    aux = captures[:text].first.value

    # Remove spaces on multilined Singleline strings
    aux.gsub!(/\\\r?\n[\n\t\r ]*/, '')

    TomlBasicString.transform_escaped_chars aux
  end
end

module TomlMultilineLiteral
  def value
    aux = captures[:text].first.value

    aux.gsub(/\\\r?\n[\n\t\r ]*/, '')
  end
end
