# Used in primitive.citrus
module TomlMultilineString
  def value
    aux = captures[:text].first.value

    # Remove spaces on multilined Singleline strings
    aux.gsub!(/\\\r?\n[\n\t\r ]*/, '')

    TomlString.transform_escaped_chars aux
  end
end
