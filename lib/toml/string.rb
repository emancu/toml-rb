# Used in primitive.citrus
module TomlString
  def value
    aux = TomlString.transform_escaped_chars first.value

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
