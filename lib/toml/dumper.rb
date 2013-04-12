module TOML
  class Dumper
    attr_reader :toml_str

    def initialize(hash)
      @toml_str = ""

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
      simple_pairs.each do |pair|
        @toml_str << "#{pair[0].to_s} = #{to_toml(pair[1])}\n"
      end

      nested_pairs.each do |pair|
        visit(pair[1], prefix.empty? ? pair[0].to_s : [prefix, pair[0]].join('.'))
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
  end
end
