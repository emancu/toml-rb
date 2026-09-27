require_relative "helper"
require "date"

class DumperTest < Minitest::Test
  def test_dump_empty
    dumped = TomlRB.dump({})
    assert_equal("", dumped)
  end

  def test_dump_types
    dumped = TomlRB.dump(string: 'TomlRB "dump"')
    assert_equal("string = \"TomlRB \\\"dump\\\"\"\n", dumped)

    dumped = TomlRB.dump(float: -13.24)
    assert_equal("float = -13.24\n", dumped)

    dumped = TomlRB.dump(int: 1234)
    assert_equal("int = 1234\n", dumped)

    dumped = TomlRB.dump(truthy: true)
    assert_equal("truthy = true\n", dumped)

    dumped = TomlRB.dump(falsey: false)
    assert_equal("falsey = false\n", dumped)

    dumped = TomlRB.dump(array: [1, 2, 3])
    assert_equal("array = [1, 2, 3]\n", dumped)

    dumped = TomlRB.dump(array: [[1, 2], %w[weird one]])
    assert_equal("array = [[1, 2], [\"weird\", \"one\"]]\n", dumped)

    dumped = TomlRB.dump(array: %w[#$ #@ #{}])
    assert_equal("array = [\"\#$\", \"\#@\", \"\#{}\"]\n", dumped)

    dumped = TomlRB.dump(time: Time.utc(1986, 8, 28, 15, 15))
    assert_equal("time = 1986-08-28T15:15:00Z\n", dumped)

    dumped = TomlRB.dump(time: Time.new(1986, 8, 28, 15, 15, 0, "+02:00"))
    assert_equal("time = 1986-08-28T15:15:00+02:00\n", dumped)

    dumped = TomlRB.dump(time: Time.utc(1986, 8, 28, 15, 15, 0, 500_000))
    assert_equal("time = 1986-08-28T15:15:00.5Z\n", dumped)

    dumped = TomlRB.dump(datetime: DateTime.new(1986, 8, 28, 15, 15))
    assert_equal("datetime = 1986-08-28T15:15:00Z\n", dumped)

    dumped = TomlRB.dump(datetime: DateTime.new(1986, 8, 28, 15, 15, 0, "+02:00"))
    assert_equal("datetime = 1986-08-28T15:15:00+02:00\n", dumped)

    dumped = TomlRB.dump(date: Date.new(1986, 8, 28))
    assert_equal("date = 1986-08-28\n", dumped)

    dumped = TomlRB.dump(regexp: /abc\n*\{/)
    assert_equal("regexp = \"/abc\\\\n*\\\\{/\"\n", dumped)
  end

  def test_dump_datetimes_round_trip
    [
      "odt = 1979-05-27T00:32:00-07:00\n",
      "odt = 1979-05-27T00:32:00.999-07:00\n",
      "ldt = 1979-05-27T00:32:00.999999\n",
      "ldt = 1979-05-27T00:32:00.123456789\n",
      "ld = 1979-05-27\n",
      "lt = 00:32:00.5\n",
      "lt = 00:32:00.123456789\n"
    ].each do |toml|
      assert_equal toml, TomlRB.dump(TomlRB.parse(toml))
    end
  end

  def test_dump_nested_attributes
    hash = {nested: {hash: {deep: true}}}
    dumped = TomlRB.dump(hash)
    assert_equal("[nested.hash]\ndeep = true\n", dumped)

    hash[:nested][:other] = 12
    dumped = TomlRB.dump(hash)
    assert_equal("[nested]\nother = 12\n[nested.hash]\ndeep = true\n", dumped)

    hash[:nested][:nest] = {again: "it never ends"}
    dumped = TomlRB.dump(hash)
    toml = <<-EOS.gsub(/^ {6}/, "")
      [nested]
      other = 12
      [nested.hash]
      deep = true
      [nested.nest]
      again = "it never ends"
    EOS

    assert_equal(toml, dumped)

    hash = {non: {'bare."keys"' => {"works" => true}}}
    dumped = TomlRB.dump(hash)
    assert_equal("[non.\"bare.\\\"keys\\\"\"]\nworks = true\n", dumped)

    hash = {hola: [{chau: 4}, {chau: 3}]}
    dumped = TomlRB.dump(hash)
    assert_equal("[[hola]]\nchau = 4\n[[hola]]\nchau = 3\n", dumped)
  end

  def test_print_empty_tables
    hash = {plugins: {cpu: {foo: "bar", baz: 1234}, disk: {}, io: {}}}
    dumped = TomlRB.dump(hash)
    toml = <<-EOS.gsub(/^ {6}/, "")
      [plugins.cpu]
      baz = 1234
      foo = "bar"
      [plugins.disk]
      [plugins.io]
    EOS

    assert_equal toml, dumped
  end

  def test_dump_array_tables
    hash = {fruit: [{physical: {color: "red"}}, {physical: {color: "blue"}}]}
    dumped = TomlRB.dump(hash)
    toml = <<-EOS.gsub(/^ {6}/, "")
      [[fruit]]
      [fruit.physical]
      color = "red"
      [[fruit]]
      [fruit.physical]
      color = "blue"
    EOS

    assert_equal toml, dumped
  end

  def test_dump_interpolation_curly
    hash = {"key" => "includes \#{variable}"}
    dumped = TomlRB.dump(hash)

    assert_equal %(key = "includes \#{variable}") + "\n", dumped
  end

  def test_dump_interpolation_at
    hash = {"key" => 'includes #@variable'}
    dumped = TomlRB.dump(hash)

    assert_equal 'key = "includes #@variable"' + "\n", dumped
  end

  def test_dump_interpolation_dollar
    hash = {"key" => 'includes #$variable'}
    dumped = TomlRB.dump(hash)

    assert_equal 'key = "includes #$variable"' + "\n", dumped
  end

  def test_dump_special_chars_in_literals
    hash = {'\t' => "escape special chars in string literals"}
    dumped = TomlRB.dump(hash)

    assert_equal %("\\\\t" = "escape special chars in string literals") + "\n", dumped
  end

  def test_dump_special_chars_in_strings
    hash = {"\t" => "escape special chars in strings"}
    dumped = TomlRB.dump(hash)

    assert_equal %("\\t" = "escape special chars in strings") + "\n", dumped
  end

  def test_dump_empty_key
    hash = {"" => "empty key"}
    dumped = TomlRB.dump(hash)

    assert_equal %("" = "empty key") + "\n", dumped
  end

  def test_dump_special_floats
    assert_equal "inf = inf\n", TomlRB.dump(inf: Float::INFINITY)
    assert_equal "inf = -inf\n", TomlRB.dump(inf: -Float::INFINITY)
    assert_equal "nan = nan\n", TomlRB.dump(nan: Float::NAN)

    # Also inside arrays and nested tables.
    assert_equal "arr = [1.0, inf, -inf, nan]\n",
      TomlRB.dump(arr: [1.0, Float::INFINITY, -Float::INFINITY, Float::NAN])
    assert_equal "[a]\nx = inf\n", TomlRB.dump(a: {x: Float::INFINITY})

    # Finite floats keep their full-precision rendering.
    assert_equal "float = 3.141592653589793\n", TomlRB.dump(float: Math::PI)
    assert_equal "float = 1.0e+100\n", TomlRB.dump(float: 1.0e+100)
    assert_equal "float = -0.0\n", TomlRB.dump(float: -0.0)
  end

  # The dumped tokens must round-trip through TomlRB's own parser, which
  # already accepts inf/-inf/nan; Ruby's Infinity/NaN spellings do not.
  def test_dump_special_floats_roundtrip
    parsed = TomlRB.parse(TomlRB.dump(pos: Float::INFINITY, neg: -Float::INFINITY))
    assert_equal Float::INFINITY, parsed["pos"]
    assert_equal(-Float::INFINITY, parsed["neg"])
    assert TomlRB.parse(TomlRB.dump(nan: Float::NAN))["nan"].nan?
  end

  # Every C0 control character (plus DEL) must survive dump -> parse, both as a
  # value and as a key. String#inspect used to leak \a \v \e (0x07/0x0B/0x1B),
  # which the parser rejects; keys with a newline slipped through bare_key?.
  def test_dump_control_chars_round_trip
    codes = (0x00..0x1f).to_a << 0x7f

    codes.each do |code|
      char = code.chr(Encoding::UTF_8)

      value_hash = {"k" => "x#{char}y"}
      dumped_value = TomlRB.dump(value_hash)
      assert_equal value_hash, TomlRB.parse(dumped_value),
        format("value with 0x%02X did not round-trip, dumped %p", code, dumped_value)

      key_hash = {"x#{char}y" => 1}
      dumped_key = TomlRB.dump(key_hash)
      assert_equal key_hash, TomlRB.parse(dumped_key),
        format("key with 0x%02X did not round-trip, dumped %p", code, dumped_key)
    end
  end

  def test_dump_reserved_control_chars_use_unicode_escape
    assert_equal %q(k = "\u0007\u000B\u001B") + "\n",
      TomlRB.dump({"k" => "\a\v\e"})
  end

  def test_dump_keeps_short_toml_escapes
    assert_equal %q(k = "\b\t\n\f\r") + "\n",
      TomlRB.dump({"k" => "\b\t\n\f\r"})
  end

  def test_dump_does_not_escape_printable_unicode
    assert_equal "k = \"café 😀\"" + "\n",
      TomlRB.dump({"k" => "café 😀"})
  end

  def test_dump_quotes_key_containing_newline
    hash = {"a\nb" => 1}
    dumped = TomlRB.dump(hash)

    assert_equal %q("a\nb" = 1) + "\n", dumped
    assert_equal hash, TomlRB.parse(dumped)
  end
end
