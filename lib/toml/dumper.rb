module TOML
  class Dumper
    attr_reader :toml_str

    def initialize(hash)
      @toml_str = ''

      visit(hash, '')
    end

    private

    def visit(hash, prefix)
      nested_pairs = []
      simple_pairs = []

      hash.keys.sort.each do |key|
        val = hash[key]
        (val.is_a?(Hash) ? nested_pairs : simple_pairs) << [key, val]
      end

      @toml_str += "[#{prefix}]\n" unless prefix.empty? || simple_pairs.empty?

      # First add simple pairs, under the prefix
      simple_pairs.each do |key, val|
        key = quote_key(key) unless bare_key? key
        @toml_str << "#{key} = #{to_toml(val)}\n"
      end

      nested_pairs.each do |key, val|
        key = quote_key(key) unless bare_key? key
        visit(val, prefix.empty? ? key.to_s : [prefix, key].join('.'))
      end
    end

    def to_toml(obj)
      case
      when obj.is_a?(Time)
        obj.strftime('%Y-%m-%dT%H:%M:%SZ')
      else
        obj.inspect
      end
    end

    def bare_key?(key)
      !!key.to_s.match(/^[a-zA-Z0-9_-]*$/)
    end

    def quote_key(key)
      '"' + key.gsub('"','\\"') + '"'
    end
  end
end
