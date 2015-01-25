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

    def accept_visitor(parser)
      parser.visit_keygroup(self)
    end
  end
end

# Used in document.citrus
module Keygroup
  def value
    TOML::Keygroup.new(captures[:key].map(&:value))
  end
end
