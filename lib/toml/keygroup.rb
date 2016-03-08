module TOML
  class Keygroup
    def initialize(nested_keys)
      @nested_keys = nested_keys
    end

    def navigate_keys(hash, visited_keys, symbolize_keys = false)
      ensure_key_not_defined(visited_keys)
      @nested_keys.each do |key|
        key = symbolize_keys ? key.to_sym : key
        hash[key] = {} unless hash.key?(key)
        element = hash[key]
        hash = element.is_a?(Array) ? element.last : element
        # check that key has not been defined before as a scalar value
        fail ValueOverwriteError.new(key) unless hash.is_a?(Hash)
      end
      hash
    end

    # Fail if the key was already defined with a ValueOverwriteError
    def ensure_key_not_defined(visited_keys)
      fail ValueOverwriteError.new(full_key) if visited_keys.include?(full_key)
      visited_keys << full_key
    end

    def accept_visitor(parser)
      parser.visit_keygroup self
    end

    def full_key
      @nested_keys.join('.')
    end
  end
  # Used in document.citrus
  module KeygroupParser
    def value
      TOML::Keygroup.new(captures[:stripped_key].map(&:value))
    end
  end
end
