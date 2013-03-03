module TOML
  class Parser
    attr_reader :hash

    def initialize(content, options = {})
      @hash = {}
      @current = @hash

      parsed = Document.parse(content)
      parsed.matches.map(&:value).compact.each do |match|
        if match.is_a? Keygroup
          @current = match.navigate_keys(@hash, options[:symbolize_keys])
        elsif match.is_a? Keyvalue
          match.assign(@current, options[:symbolize_keys])
        end
      end
    end
  end
end
