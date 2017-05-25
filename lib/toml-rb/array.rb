module TomlRB
  module ArrayParser
    def value
      elements = captures[:elements].first
      return [] unless elements

      if elements.captures.key? :string
        elements.captures[:string].map(&:value)
      else
        eval(to_str)
      end
    end
  end
end
