# Used in primitive.citrus
module TomlString
  def value
    aux = first.value
    s = 0
    o = []
    while s < aux.length
      if aux[s] == '\\'
        s += 1
        case aux[s]
        when 't' then o << "\t"
        when 'n' then o << "\n"
        when '\\' then o << '\\'
        when '"' then o << '"'
        when 'r' then o << "\r"
        when '0' then o << "\0"
        else
          o << '\\' << aux[s]
        end
      else
        o << aux[s]
      end
      s += 1
    end
    o[1...-1].join
  end
end
