module TOML
  class ValueOverwriteError < StandardError; end

  class Keyvalue
    def initialize(key, value)
      @key, @value = key, value
    end

    def assign(hash)
      if hash[@key]
        raise ValueOverwriteError
      else
        hash[@key] = @value
      end
    end
  end
end

# Used in toml.citrus
module Keyvalue
  def value
    TOML::Keyvalue.new(key.value, v.value)
  end
end
