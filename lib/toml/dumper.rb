module TOML
  class Dumper
    attr_reader :toml_str

    def initialize(hash)
      @toml_str = ''

      visit(hash, [])
    end

    private

    def visit(hash, prefix, extra_brackets = false)
      nested_pairs = []
      simple_pairs = []
      table_array_pairs = []

      hash.keys.sort.each do |key|
        val = hash[key]
        element = [key, val]

        if val.is_a? Hash
          nested_pairs << element
        elsif val.is_a?(Array) && val.first.is_a?(Hash)
          table_array_pairs << element
        else
          simple_pairs << element
        end
      end

      unless prefix.empty? || simple_pairs.empty?
        print_prefix prefix, extra_brackets
      end

      # First add simple pairs, under the prefix
      simple_pairs.each do |key, val|
        key = quote_key(key) unless bare_key? key
        @toml_str << "#{key} = #{to_toml(val)}\n"
      end

      nested_pairs.each do |key, val|
        key = quote_key(key) unless bare_key? key

        visit val, prefix + [key], false
      end

      table_array_pairs.each do |key, val|
        key = quote_key(key) unless bare_key? key
        aux_prefix = prefix + [key]

        val.each do |child|
          if child.empty?
            print_prefix aux_prefix, true
          else
            visit child, aux_prefix, true
          end
        end
      end
    end

    def print_prefix(prefix, extra_brackets = false)
      new_prefix = prefix.join('.')
      new_prefix = '[' + new_prefix + ']' if extra_brackets

      @toml_str += "[" + new_prefix + "]\n"
    end

    def to_toml(obj)
      if obj.is_a? Time
        obj.strftime('%Y-%m-%dT%H:%M:%SZ')
      else
        obj.inspect
      end
    end

    def bare_key?(key)
      !!key.to_s.match(/^[a-zA-Z0-9_-]*$/)
    end

    def quote_key(key)
      '"' + key.gsub('"', '\\"') + '"'
    end
  end
end
