require_relative "helper"

class GrammarTest < Minitest::Test
  def test_comment
    match = TomlRB::Document.parse(" # A comment", root: :comment)
    assert_nil(match.value)
  end

  def test_comment_with_many_spaces
    assert_equal({}, TomlRB.parse("#" + " " * 10_000))
    assert_equal({"a" => 1}, TomlRB.parse("#" + " " * 10_000 + "x\r\na=1"))
  end

  def test_key
    match = TomlRB::Document.parse("bad_key-", root: :key)
    assert_equal("bad_key-", match.value.first)

    match = TomlRB::Document.parse('"123.ʎǝʞ.#?"', root: :key)
    assert_equal("123.ʎǝʞ.#?", match.value.first)
  end

  def test_table
    indentation_alternatives_for("[akey]") do |str|
      match = TomlRB::Document.parse(str, root: :table)
      assert_equal(TomlRB::Table, match.value.class)
      assert_equal(["akey"], match.value.instance_variable_get(:@dotted_keys))
    end

    match = TomlRB::Document.parse("[owner.emancu]", root: :table)
    assert_equal(%w[owner emancu],
      match.value.instance_variable_get(:@dotted_keys))

    match = TomlRB::Document.parse('["owner.emancu"]', root: :table)
    assert_equal(%w[owner.emancu],
      match.value.instance_variable_get(:@dotted_keys))

    match = TomlRB::Document.parse('["first key"."second key"]', root: :table)
    assert_equal(["first key", "second key"],
      match.value.instance_variable_get(:@dotted_keys))

    match = TomlRB::Document.parse("[ owner . emancu ]", root: :table)
    assert_equal(%w[owner emancu],
      match.value.instance_variable_get(:@dotted_keys))

    assert_raises Citrus::ParseError do
      TomlRB::Document.parse("[ owner emancu ]", root: :table)
    end
  end

  def test_keyvalue
    indentation_alternatives_for('key = "value"') do |str|
      match = TomlRB::Document.parse(str, root: :keyvalue)
      assert_equal(TomlRB::Keyvalue, match.value.class)

      keyvalue = match.value
      assert_equal("key", keyvalue.instance_variable_get(:@dotted_keys).first)
      assert_equal("value", keyvalue.instance_variable_get(:@value))
    end

    indentation_alternatives_for('key1."key2".key3 = "value"') do |str|
      match = TomlRB::Document.parse(str, root: :keyvalue)
      assert_equal(TomlRB::Keyvalue, match.value.class)

      keyvalue = match.value
      assert_equal("key1", keyvalue.instance_variable_get(:@dotted_keys)[0])
      assert_equal("key2", keyvalue.instance_variable_get(:@dotted_keys)[1])
      assert_equal("key3", keyvalue.instance_variable_get(:@dotted_keys)[2])
      assert_equal("value", keyvalue.instance_variable_get(:@value))
    end
  end

  def test_string
    match = TomlRB::Document.parse('"TomlRB-Example, should work."', root: :string)
    assert_equal("TomlRB-Example, should work.", match.value)
  end

  def test_unterminated_basic_string_with_many_backslashes
    assert_raises TomlRB::ParseError do
      TomlRB.parse('a="' + "\\" * 10_000)
    end
  end

  def test_unterminated_basic_string_with_escaped_quote
    assert_raises TomlRB::ParseError do
      TomlRB.parse('a="x\"')
    end
  end

  def test_basic_string_with_reserved_escape
    assert_raises TomlRB::ParseError do
      TomlRB.parse('a="\q"')
    end
  end

  def test_literal_string_with_backslash_quote
    assert_raises TomlRB::ParseError do
      TomlRB.parse("a='x\\'y'")
    end
  end

  def test_literal_strings_ending_in_backslashes
    assert_equal({"a" => ["C:\\", "D:\\"]}, TomlRB.parse("a=['C:\\', 'D:\\']"))
  end

  def test_literal_string_before_comment_with_quote
    assert_equal({"a" => "C:\\"}, TomlRB.parse("a='C:\\' # '"))
  end

  def test_multiline_string
    match = TomlRB::Document.parse('"""\tOne\nTwo\e\x41"""', root: :multiline_string)
    assert_equal "\tOne\nTwo\eA", match.value

    to_parse = '"""\
    One \
    Two\
    """'

    match = TomlRB::Document.parse(to_parse, root: :multiline_string)
    assert_equal "One Two", match.value
  end

  def test_empty_multiline_string
    to_parse = '""""""'

    match = TomlRB::Document.parse(to_parse, root: :multiline_string)
    assert_equal "", match.value
  end

  def test_multiline_strings_trim_one_newline
    assert_equal({"a" => "    indented"}, TomlRB.parse(%(a = """\n    indented""")))
    assert_equal({"a" => "\nsecond"}, TomlRB.parse(%(a = """\n\nsecond""")))
    assert_equal({"a" => "\nsecond"}, TomlRB.parse(%(a = '''\r\n\nsecond''')))
  end

  def test_multiline_string_line_ending_backslash
    assert_equal({"a" => "foo\\\nbar"}, TomlRB.parse(%(a = """foo\\\\\nbar""")))
    assert_equal({"a" => "xy"}, TomlRB.parse(%(a = """x\\ \n  y""")))
  end

  def test_multiline_literal_keeps_line_ending_backslash
    assert_equal({"a" => "foo\\\nbar"}, TomlRB.parse(%(a = '''foo\\\nbar''')))
  end

  def test_multiline_strings_closing_quotes
    assert_equal({"a" => 'a"""b'}, TomlRB.parse('a = """a\"""b"""'))
    assert_equal({"a" => 'x""'}, TomlRB.parse('a = """x"""""'))
    assert_equal({"a" => "x''"}, TomlRB.parse("a = '''x'''''"))

    ['a = """x""""""', "a = '''x''''''", 'a = """\"""'].each do |toml|
      assert_raises(TomlRB::ParseError) { TomlRB.parse(toml) }
    end
  end

  def test_unicode_escapes_must_be_scalar_values
    ['"\uD800"', '"\uDFFF"', '"\U00110000"', '"\UFFFFFFFF"'].each do |str|
      assert_raises(TomlRB::ParseError) { TomlRB::Document.parse(str, root: :string).value }
    end
  end

  def test_special_characters
    match = TomlRB::Document.parse('"\u0000 \" \t \n \r \e"', root: :string)
    assert_equal("\u0000 \" \t \n \r \e", match.value)

    match = TomlRB::Document.parse('"\x41 \x00 \xff"', root: :string)
    assert_equal("A \u0000 ÿ", match.value)

    assert_raises TomlRB::ParseError do
      TomlRB::Document.parse('"\x1"', root: :string).value
    end

    assert_raises TomlRB::ParseError do
      TomlRB::Document.parse('"\0"', root: :string).value
    end

    match = TomlRB::Document.parse('"C:\\\\Documents\\\\nada.exe"', root: :string)
    assert_equal("C:\\Documents\\nada.exe", match.value)
  end

  def test_bool
    match = TomlRB::Document.parse("true", root: :bool)
    assert_equal(true, match.value)

    match = TomlRB::Document.parse("false", root: :bool)
    assert_equal(false, match.value)
  end

  def test_integer
    match = TomlRB::Document.parse("+99", root: :integer)
    assert_equal(99, match.value)

    match = TomlRB::Document.parse("42", root: :integer)
    assert_equal(42, match.value)

    match = TomlRB::Document.parse("0", root: :integer)
    assert_equal(0, match.value)

    %w[+0 -0].each do |integer|
      assert_equal(0, TomlRB::Document.parse(integer, root: :integer).value)
    end

    match = TomlRB::Document.parse("-17", root: :integer)
    assert_equal(-17, match.value)

    match = TomlRB::Document.parse("1_000", root: :integer)
    assert_equal(1_000, match.value)

    match = TomlRB::Document.parse("5_349_221", root: :integer)
    assert_equal(5_349_221, match.value)

    match = TomlRB::Document.parse("1_2_3_4_5", root: :integer)
    assert_equal(1_2_3_4_5, match.value)

    match = TomlRB::Document.parse("0xDEADBEEF", root: :integer)
    assert_equal(0xDEADBEEF, match.value)

    match = TomlRB::Document.parse("0xdeadbeef", root: :integer)
    assert_equal(0xdeadbeef, match.value)

    match = TomlRB::Document.parse("0xdead_beef", root: :integer)
    assert_equal(0xdead_beef, match.value)

    match = TomlRB::Document.parse("0o01234567", root: :integer)
    assert_equal(0o01234567, match.value)

    match = TomlRB::Document.parse("0o755", root: :integer)
    assert_equal(0o755, match.value)

    match = TomlRB::Document.parse("0b11010110", root: :integer)
    assert_equal(0b11010110, match.value)
  end

  def test_float
    match = TomlRB::Document.parse("+1.0", root: :float)
    assert_equal(+1.0, match.value)

    match = TomlRB::Document.parse("3.1415", root: :float)
    assert_equal(3.1415, match.value)

    match = TomlRB::Document.parse("-0.01", root: :float)
    assert_equal(-0.01, match.value)

    match = TomlRB::Document.parse("5e+22", root: :float)
    assert_equal(5e+22, match.value)

    match = TomlRB::Document.parse("1e6", root: :float)
    assert_equal(1e6, match.value)

    %w[1e06 1e+06 1e0_6 1.0e06].each do |float|
      assert_equal(1e6, TomlRB::Document.parse(float, root: :float).value)
    end

    match = TomlRB::Document.parse("1e-06", root: :float)
    assert_equal(1e-6, match.value)

    match = TomlRB::Document.parse("-2E-2", root: :float)
    assert_equal(-2E-2, match.value)

    match = TomlRB::Document.parse("6.626e-34", root: :float)
    assert_equal(6.626e-34, match.value)

    match = TomlRB::Document.parse("224_617.445_991_228", root: :float)
    assert_equal(224_617.445_991_228, match.value)

    match = TomlRB::Document.parse("inf", root: :float)
    assert_equal(Float::INFINITY, match.value)

    match = TomlRB::Document.parse("+inf", root: :float)
    assert_equal(Float::INFINITY, match.value)

    match = TomlRB::Document.parse("-inf", root: :float)
    assert_equal(-Float::INFINITY, match.value)

    match = TomlRB::Document.parse("nan", root: :float)
    assert(match.value.nan?)

    match = TomlRB::Document.parse("+nan", root: :float)
    assert(match.value.nan?)

    match = TomlRB::Document.parse("-nan", root: :float)
    assert(match.value.nan?)
  end

  def test_signed_numbers
    match = TomlRB::Document.parse("+26", root: :number)
    assert_equal(26, match.value)

    match = TomlRB::Document.parse("-26", root: :number)
    assert_equal(-26, match.value)

    match = TomlRB::Document.parse("1.69", root: :number)
    assert_equal(1.69, match.value)

    match = TomlRB::Document.parse("-1.69", root: :number)
    assert_equal(-1.69, match.value)
  end

  def test_expressions_with_comments
    match = TomlRB::Document.parse("[shouldwork] # with comment", root: :table)
    assert_equal(["shouldwork"],
      match.value.instance_variable_get(:@dotted_keys))

    match = TomlRB::Document.parse("works = true # with comment", root: :keyvalue_line).value
    assert_equal("works", match.instance_variable_get(:@dotted_keys).first)
    assert_equal(true, match.instance_variable_get(:@value))
  end

  def test_array
    match = TomlRB::Document.parse("[]", root: :array)
    assert_equal([], match.value)

    match = TomlRB::Document.parse("[ 2, 4]", root: :array)
    assert_equal([2, 4], match.value)

    match = TomlRB::Document.parse("[ 2.4, 4.72]", root: :array)
    assert_equal([2.4, 4.72], match.value)

    match = TomlRB::Document.parse("[12:00:00,5]", root: :array)
    assert_equal([TomlRB::LocalTime.utc(1970, 1, 1, 12), 5], match.value)

    match = TomlRB::Document.parse('[ "hey", "TomlRB"]', root: :array)
    assert_equal(%w[hey TomlRB], match.value)

    match = TomlRB::Document.parse('[ ["hey", "TomlRB"], [2,4] ]', root: :array)
    assert_equal([%w[hey TomlRB], [2, 4]], match.value)

    match = TomlRB::Document.parse("[ { one = 1 }, { two = 2, three = 3} ]",
      root: :array)
    assert_equal([{"one" => 1}, {"two" => 2, "three" => 3}], match.value)
  end

  def test_empty_array
    # test that [] is parsed as array and not as inline table array
    match = TomlRB::Document.parse("a = []", root: :keyvalue).value
    assert_equal [], match.value
  end

  def test_multiline_array
    multiline_array = "[ \"hey\",\n   \"ho\",\n\t \"lets\", \"go\",\n ]"
    match = TomlRB::Document.parse(multiline_array, root: :array)
    assert_equal(%w[hey ho lets go], match.value)

    multiline_array = "[\n#1,\n2,\n# 3\n]"
    match = TomlRB::Document.parse(multiline_array, root: :array)
    assert_equal([2], match.value)

    multiline_array = "[\n# comment\n#, more comments\n4]"
    match = TomlRB::Document.parse(multiline_array, root: :array)
    assert_equal([4], match.value)

    multiline_array = "[\n  1,\n  # 2,\n  3 ,\n]"
    match = TomlRB::Document.parse(multiline_array, root: :array)
    assert_equal([1, 3], match.value)

    multiline_array = "[\n  1 , # useless comment\n  # 2,\n  3 #other comment\n]"
    match = TomlRB::Document.parse(multiline_array, root: :array)
    assert_equal([1, 3], match.value)
  end

  # Dates are really hard to test from JSON, due the imposibility to represent
  # datetimes without quotes.
  def test_datetime
    match = TomlRB::Document.parse("1979-05-27T07:32:00Z", root: :datetime)
    assert_equal(Time.utc(1979, 5, 27, 7, 32, 0), match.value)

    match = TomlRB::Document.parse("1979-05-27T00:32:00-07:00", root: :datetime)
    assert_equal(Time.new(1979, 5, 27, 0, 32, 0, "-07:00"), match.value)

    match = TomlRB::Document.parse("1979-05-27T00:32:00.999999-07:00", root: :datetime)
    assert_equal(Time.new(1979, 5, 27, 0, 32, 0.999999r, "-07:00"), match.value)

    match = TomlRB::Document.parse("1979-05-27 07:32:00Z", root: :datetime)
    assert_equal(Time.utc(1979, 5, 27, 7, 32, 0), match.value)

    match = TomlRB::Document.parse("1979-05-27T07:32:00", root: :datetime)
    assert_equal(Time.local(1979, 5, 27, 7, 32, 0), match.value)

    match = TomlRB::Document.parse("1979-05-27T00:32:00.999999", root: :datetime)
    assert_equal(Time.local(1979, 5, 27, 0, 32, 0, 999999), match.value)

    match = TomlRB::Document.parse("1979-05-27", root: :datetime)
    assert_equal(Time.local(1979, 5, 27), match.value)

    match = TomlRB::Document.parse("07:32:00", root: :datetime)
    assert_equal(Time.at(3600 * 7 + 60 * 32), match.value)

    match = TomlRB::Document.parse("00:32:00.999999", root: :datetime)
    assert_equal(Time.at(60 * 32, 999999), match.value)

    match = TomlRB::Document.parse("1979-05-27T07:32-07:00", root: :datetime)
    assert_equal(Time.new(1979, 5, 27, 7, 32, 0, "-07:00"), match.value)

    match = TomlRB::Document.parse("10:30:45", root: :datetime)
    assert_equal(Time.utc(1970, 1, 1, 10, 30, 45), match.value)

    ["10:30.5", "2025-01-01T10:30.5", "1979-05-27T07:32.5Z", "1979-05-27T07:32.5-07:00"].each do |datetime|
      assert_raises Citrus::ParseError do
        TomlRB::Document.parse(datetime, root: :datetime)
      end
    end
  end

  def test_datetime_fractional_seconds
    {
      "2025-01-01T10:30:00.123456Z" => 123_456_000,
      "2025-01-01T10:30:00.123456789Z" => 123_456_789,
      "2025-01-01T10:30:00.123456789999Z" => 123_456_789,
      "1979-05-27T00:32:00.999-07:00" => 999_000_000,
      "2025-01-01T10:30:00.123456" => 123_456_000,
      "2025-01-01T10:30:00.123456789" => 123_456_789,
      "2025-01-01T10:30:00.123456789999" => 123_456_789,
      "10:30:00.123456" => 123_456_000,
      "10:30:00.123456789" => 123_456_789,
      "10:30:00.123456789999" => 123_456_789
    }.each do |datetime, nsec|
      assert_equal nsec, TomlRB::Document.parse(datetime, root: :datetime).value.nsec
    end
  end

  def test_datetime_boundaries
    {
      "2000-02-29t23:59:59z" => Time.utc(2000, 2, 29, 23, 59, 59),
      "2000-02-29t23:59:59+18:00" => Time.new(2000, 2, 29, 23, 59, 59, "+18:00"),
      "2000-02-29T23:59:59-18:00" => Time.new(2000, 2, 29, 23, 59, 59, "-18:00"),
      "2000-02-29t23:59:59" => TomlRB::LocalDateTime.local(2000, 2, 29, 23, 59, 59),
      "2000-02-29" => TomlRB::LocalDate.local(2000, 2, 29),
      "1582-10-10" => TomlRB::LocalDate.local(1582, 10, 10),
      "2016-12-31T23:59:60.5Z" => Time.utc(2016, 12, 31, 23, 59, 60.5r),
      "2016-12-31T23:59:60.5" => TomlRB::LocalDateTime.local(2016, 12, 31, 23, 59, 60.5r),
      "23:59:60.5" => TomlRB::LocalTime.utc(1970, 1, 1, 23, 59, 60.5r)
    }.each do |datetime, expected|
      actual = TomlRB::Document.parse(datetime, root: :datetime).value
      assert_equal expected, actual
      assert_instance_of expected.class, actual
    end
  end

  def test_inline_table
    match = TomlRB::Document.parse("{ }", root: :inline_table)
    assert_equal({}, match.value.value)

    match = TomlRB::Document.parse("{ simple = true, params = 2 }", root: :inline_table)
    assert_equal({"simple" => true, "params" => 2}, match.value.value)

    match = TomlRB::Document.parse("{ nest = { really = { hard = true } } }",
      root: :inline_table)
    assert_equal({"nest" => {"really" => {"hard" => true}}}, match.value.value)
    assert_equal({nest: {really: {hard: true}}}, match.value.value(true))
  end

  private

  # Creates all the alternatives of valid indentations to test
  def indentation_alternatives_for(str)
    [str, "  #{str}", "\t#{str}", "\t\t#{str}"].each do |alternative|
      yield(alternative)
    end
  end
end
