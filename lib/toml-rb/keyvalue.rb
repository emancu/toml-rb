require_relative "inline_table"

module TomlRB
  class Keyvalue
    attr_reader :dotted_keys, :value, :symbolize_keys

    def initialize(dotted_keys, value)
      @dotted_keys = dotted_keys
      @value = value
      @symbolize_keys = false
    end

    def assign(hash, tables, symbolize_keys = false)
      @symbolize_keys = symbolize_keys
      *keys, last_key = symbolize_keys ? @dotted_keys.map(&:to_sym) : @dotted_keys

      keys.each do |key|
        unless hash.key?(key)
          hash[key] = {}
          tables[hash[key]] = :dotted
        end
        hash = hash[key]
        fail ValueOverwriteError.new(key) unless [:implicit, :dotted].include?(tables[hash])

        tables[hash] = :dotted
      end
      fail ValueOverwriteError.new(last_key) if hash.key?(last_key)

      hash[last_key] = visit_value(@value)
    end

    def accept_visitor(parser)
      parser.visit_keyvalue self
    end

    private

    def visit_value(a_value)
      return a_value.map { |v| visit_value(v) } if a_value.is_a?(Array)
      return a_value unless a_value.respond_to? :accept_visitor

      a_value.accept_visitor self
    end
  end
end
