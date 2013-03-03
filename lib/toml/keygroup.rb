module TOML
  class Keygroup
    def initialize(nested_keys)
      @nested_keys = nested_keys
    end

    def navigate_keys(hash, symbolize_keys = false)
      @nested_keys.each do |key|
        key = symbolize_keys ? key.to_sym : key
        hash[key] = {} unless hash[key]
        hash = hash[key]
      end

      hash
    end
  end
end

# Used in toml.citrus
module Keygroup
  def value
    TOML::Keygroup.new(nested_keys.to_s.split("."))
  end
end
