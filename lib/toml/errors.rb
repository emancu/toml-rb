module TOML
  # Parent class for all TOML errors
  Error = Class.new(StandardError)

  # Error related to parsing.
  ParseError = Class.new(Error)

  # Overwrite error
  class ValueOverwriteError < Error
    attr_accessor :key

    def initialize(key)
      @key = key
      super "Key #{key.inspect} is defined more than once"
    end
  end

  class EscapeSequenceReserved < Error
    attr_accessor :sequence

    def initialize(sequence)
      @sequence = sequence
      super "Escape sequence `#{sequence}` is reserved"
    end
  end
end
