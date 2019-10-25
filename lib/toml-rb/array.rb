module TomlRB
  module ArrayParser
    def value
      elements = captures[:array_elements].first
      return elements ? elements.value : []
    end
  end
end
