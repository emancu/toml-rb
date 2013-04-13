module TOML
  class Parser
    attr_reader :hash

    def initialize(content, options = {})
      @hash = {}
      @current = @hash
      @symbolize_keys = options[:symbolize_keys]

      parsed = Document.parse(content)
      parsed.matches.map(&:value).compact.each {|match| match.commit_into_hash(self)}
    end

    def commit_keygroup_into_hash(keygroup)
      @current = keygroup.navigate_keys(@hash, @symbolize_keys)
    end

    def commit_keyvalue_into_hash(keyvalue)
      keyvalue.assign(@current, @symbolize_keys)
    end
  end
end
