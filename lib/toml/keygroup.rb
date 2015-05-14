module TOML
  class Keygroup
    def initialize(nested_keys)
      @nested_keys = nested_keys
    end

    def navigate_keys(hash, symbolize_keys = false)
      last_index = @nested_keys.length - 1
      @nested_keys.each_with_index do |key, i|
        key = symbolize_keys ? key.to_sym : key
        # do not allow to define more than once just the last key
        if i == last_index && hash.key?(key)
          fail ValueOverwriteError.new(key)
        end
        hash[key] = {} unless hash.key?(key)
        element = hash[key]
        hash = element.is_a?(Array) ? element.last : element
        # check that key has not been defined before as a scalar value
        fail ValueOverwriteError.new(key) unless hash.is_a?(Hash)
      end

      hash
    end

    def accept_visitor(parser)
      parser.visit_keygroup self
    end
  end
end

# Used in document.citrus
module Keygroup
  def value
    TOML::Keygroup.new(captures[:key].map(&:value))
  end
end
