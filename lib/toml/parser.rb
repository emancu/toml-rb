module TOML
  class Parser
    attr_reader :hash

    def initialize(content)
      @hash = {}
      @current = @hash

      parsed = Document.parse(content)
      parsed.matches.map(&:value).compact.each do |match|
        if match.is_a? Keygroup
          @current = match.navigate_keys(@hash)
        elsif match.is_a? Keyvalue
          match.assign(@current)
        end
      end
    end
  end
end
