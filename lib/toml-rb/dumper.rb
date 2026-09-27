# frozen_string_literal: true

require "date"

module TomlRB
  class Dumper
    # TOML basic strings only allow these short escapes; every other control
    # character must be written as \uXXXX (TOML 1.0.0 spec).
    BASIC_ESCAPES = {
      "\\" => "\\\\",
      "\"" => "\\\"",
      "\b" => "\\b",
      "\t" => "\\t",
      "\n" => "\\n",
      "\f" => "\\f",
      "\r" => "\\r"
    }.freeze

    attr_reader :toml_str

    def initialize(hash)
      @toml_str = ""

      visit(hash, [])
    end

    private

    def visit(hash, prefix, extra_brackets = false)
      simple_pairs, nested_pairs, table_array_pairs = sort_pairs hash

      if prefix.any? && (simple_pairs.any? || hash.empty?)
        print_prefix prefix, extra_brackets
      end

      dump_pairs simple_pairs, nested_pairs, table_array_pairs, prefix
    end

    def sort_pairs(hash)
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

      [simple_pairs, nested_pairs, table_array_pairs]
    end

    def dump_pairs(simple, nested, table_array, prefix = [])
      # First add simple pairs, under the prefix
      dump_simple_pairs simple
      dump_nested_pairs nested, prefix
      dump_table_array_pairs table_array, prefix
    end

    def dump_simple_pairs(simple_pairs)
      simple_pairs.each do |key, val|
        key = quote_key(key) unless bare_key? key
        @toml_str += "#{key} = #{to_toml(val)}\n"
      end
    end

    def dump_nested_pairs(nested_pairs, prefix)
      nested_pairs.each do |key, val|
        key = quote_key(key) unless bare_key? key

        visit val, prefix + [key], false
      end
    end

    def dump_table_array_pairs(table_array_pairs, prefix)
      table_array_pairs.each do |key, val|
        key = quote_key(key) unless bare_key? key
        aux_prefix = prefix + [key]

        val.each do |child|
          print_prefix aux_prefix, true
          args = sort_pairs(child) << aux_prefix

          dump_pairs(*args)
        end
      end
    end

    def print_prefix(prefix, extra_brackets = false)
      new_prefix = prefix.join(".")
      new_prefix = "[" + new_prefix + "]" if extra_brackets

      @toml_str += "[" + new_prefix + "]\n"
    end

    def to_toml(obj)
      if obj.is_a?(LocalDate)
        obj.strftime("%Y-%m-%d")
      elsif obj.is_a?(LocalTime)
        obj.strftime("%H:%M:%S") + sec_fraction(obj)
      elsif obj.is_a?(LocalDateTime)
        obj.strftime("%Y-%m-%dT%H:%M:%S") + sec_fraction(obj)
      elsif obj.is_a?(Time) || obj.is_a?(DateTime)
        zone = obj.strftime("%:z").sub("+00:00", "Z")
        obj.strftime("%Y-%m-%dT%H:%M:%S") + sec_fraction(obj) + zone
      elsif obj.is_a?(Date)
        obj.strftime("%Y-%m-%d")
      elsif obj.is_a?(Regexp)
        obj.inspect.inspect
      elsif obj.is_a?(String)
        escape_string(obj)
      elsif obj.is_a?(Array)
        "[" + obj.map(&method(:to_toml)).join(", ") + "]"
      elsif obj.is_a?(Float) && (obj.nan? || obj.infinite?)
        # Ruby renders these as Infinity/-Infinity/NaN, which are invalid TOML.
        if obj.nan?
          "nan"
        elsif obj.negative?
          "-inf"
        else
          "inf"
        end
      else
        obj.inspect
      end
    end

    def bare_key?(key)
      !!key.to_s.match(/\A[a-zA-Z0-9_-]+\z/)
    end

    # Quote and escape a key as a TOML basic string.
    def quote_key(key)
      escape_string(key.to_s)
    end

    # Serialize a Ruby string as a TOML basic string. Ruby's String#inspect
    # emits \a and \v, which are not TOML escapes, and \e, which is not a TOML 1.0
    # escape. Write ESC as \u001B to keep the output valid TOML 1.0.
    def escape_string(str)
      escaped = str.gsub(/[\x00-\x1f\x7f"\\]/) do |char|
        BASIC_ESCAPES[char] || format('\\u%04X', char.ord)
      end

      "\"#{escaped}\""
    end

    def sec_fraction(time)
      time.strftime(".%6N").sub(/\.?0+\z/, "")
    end
  end
end
