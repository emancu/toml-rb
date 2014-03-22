module TOML
  class ValueOverwriteError < StandardError; end

  class Keyvalue
    def initialize(key, value)
      @key, @value = key, value
    end

    def assign(hash, symbolize_keys = false)
      key = symbolize_keys ? @key.to_sym : @key
      raise ValueOverwriteError if hash[key]
      hash[key] = @value
    end

    def accept_visitor(parser)
      parser.visit_keyvalue(self)
    end
  end
end

# Used in document.citrus
module Keyvalue
  def value
    key, v = [:key, :v].map{|x| captures[x].first }
    TOML::Keyvalue.new(key.value, v.value)
  end
end
