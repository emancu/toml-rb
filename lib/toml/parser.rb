module TOML
  class Parser
    attr_accessor :current
    attr_reader :hash

    def initialize(content, options = {})
      @hash = {}
      @current = @hash

      parsed = Document.parse(content)
      parsed.matches.map(&:value).compact.each do |match|
        match.commit_to_hash(self, options[:symbolize_keys])
      end
    end
  end
end
