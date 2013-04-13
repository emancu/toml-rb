module TOML
  class Parser
    attr_reader :hash

    def initialize(content, options = {})
      @hash = {}
      @current = @hash

      parsed = Document.parse(content)
      parsed.matches.map(&:value).compact.each do |match|
        match.commit_into_hash(self, options[:symbolize_keys])
      end
    end

    def commit_keygroup_into_hash(keygroup, symbolize_keys)
      @current = keygroup.navigate_keys(@hash, symbolize_keys)
    end

    def commit_keyvalue_into_hash(keyvalue, symbolize_keys)
      keyvalue.assign(@current, symbolize_keys)
    end
  end
end
