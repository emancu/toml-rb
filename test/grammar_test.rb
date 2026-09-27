require_relative "helper"

class GrammarTest < Minitest::Test
  def test_comment
    assert_equal({}, TomlRB.parse(" # A comment"))
  end

  def test_comment_with_many_spaces
    assert_equal({}, TomlRB.parse("#" + " " * 10_000))
    assert_equal({"a" => 1}, TomlRB.parse("#" + " " * 10_000 + "x\r\na=1"))
  end

  def test_comments_reject_control_characters
    ["\0", "\x7f", "\r"].each do |char|
      assert_raises(TomlRB::ParseError) { TomlRB.parse("# x#{char}y\na = 1") }
    end
    assert_raises(TomlRB::ParseError) { TomlRB.parse("a = [1 # x\r, 2]") }
  end

  def test_comments_allow_tabs_and_crlf
    assert_equal({"a" => 1}, TomlRB.parse("# x\ty\r\na = 1\r\n#\t"))
  end

  def test_key
    assert_equal({"bad_key-" => 1}, TomlRB.parse("bad_key- = 1"))
    assert_equal({"123.ʎǝʞ.#?" => 1}, TomlRB.parse('"123.ʎǝʞ.#?" = 1'))
  end

  def test_table
    indentation_alternatives_for("[akey]") do |str|
      parsed = TomlRB.parse(str)
      assert_equal({"akey" => {}}, parsed)
    end

    assert_equal({"owner" => {"emancu" => {}}}, TomlRB.parse("[owner.emancu]"))
    assert_equal({"owner.emancu" => {}}, TomlRB.parse('["owner.emancu"]'))
    assert_equal({"first key" => {"second key" => {}}}, TomlRB.parse('["first key"."second key"]'))
    assert_equal({"owner" => {"emancu" => {}}}, TomlRB.parse("[ owner . emancu ]"))

    assert_raises TomlRB::ParseError do
      TomlRB.parse("[ owner emancu ]")
    end
  end

  def test_keyvalue
    indentation_alternatives_for('key = "value"') do |str|
      parsed = TomlRB.parse(str)
      assert_equal({"key" => "value"}, parsed)
    end

    indentation_alternatives_for('key1."key2".key3 = "value"') do |str|
      parsed = TomlRB.parse(str)
      assert_equal({"key1" => {"key2" => {"key3" => "value"}}}, parsed)
    end
  end

  def test_string
    assert_equal("TomlRB-Example, should work.", value_of('"TomlRB-Example, should work."'))
  end

  def test_strings_reject_control_characters
    ['"', "'", '"""', "'''"].each do |quote|
      ["\0", "\x7f", "\r"].each do |char|
        assert_raises(TomlRB::ParseError) { TomlRB.parse("a = #{quote}x#{char}y#{quote}") }
      end
    end
    assert_raises(TomlRB::ParseError) { TomlRB.parse("a = \"\"\"x\\\ry\"\"\"") }
    assert_raises(TomlRB::ParseError) { TomlRB.parse("a = \"\"\"x\\\n\ry\"\"\"") }
  end

  def test_strings_allow_tabs
    ['"', "'", '"""', "'''"].each do |quote|
      assert_equal({"a" => "x\ty"}, TomlRB.parse("a = #{quote}x\ty#{quote}"))
    end
  end

  def test_multiline_strings_allow_crlf
    ['"""', "'''"].each do |quote|
      assert_equal({"a" => "x\r\ny"}, TomlRB.parse("a = #{quote}\r\nx\r\ny#{quote}\r\n"))
    end
    assert_equal({"a" => "xy"}, TomlRB.parse("a = \"\"\"x\\\r\n\ty\"\"\""))
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
    assert_equal "\tOne\nTwo\eA", value_of('"""\tOne\nTwo\e\x41"""')

    to_parse = '"""\
    One \
    Two\
    """'

    assert_equal "One Two", value_of(to_parse)
  end

  def test_empty_multiline_string
    to_parse = '""""""'

    assert_equal "", value_of(to_parse)
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
      assert_raises(TomlRB::ParseError) { value_of(str) }
    end
  end

  def test_special_characters
    assert_equal("\u0000 \" \t \n \r \e", value_of('"\u0000 \" \t \n \r \e"'))

    assert_equal("A \u0000 ÿ", value_of('"\x41 \x00 \xff"'))

    assert_raises TomlRB::ParseError do
      value_of('"\x1"')
    end

    assert_raises TomlRB::ParseError do
      value_of('"\0"')
    end

    assert_equal("C:\\Documents\\nada.exe", value_of('"C:\\\\Documents\\\\nada.exe"'))
  end

  def test_bool
    assert_equal(true, value_of("true"))

    assert_equal(false, value_of("false"))
  end

  def test_integer
    assert_toml_value(99, "+99")

    assert_toml_value(42, "42")

    assert_toml_value(0, "0")

    %w[+0 -0].each do |integer|
      assert_toml_value(0, integer)
    end

    assert_toml_value(-17, "-17")

    assert_toml_value(1_000, "1_000")

    assert_toml_value(5_349_221, "5_349_221")

    assert_toml_value(1_2_3_4_5, "1_2_3_4_5")

    assert_toml_value(0xDEADBEEF, "0xDEADBEEF")

    assert_toml_value(0xdeadbeef, "0xdeadbeef")

    assert_toml_value(0xdead_beef, "0xdead_beef")

    assert_toml_value(0o01234567, "0o01234567")

    assert_toml_value(0o755, "0o755")

    assert_toml_value(0b11010110, "0b11010110")
  end

  def test_float
    assert_toml_value(+1.0, "+1.0")

    assert_toml_value(3.1415, "3.1415")

    assert_toml_value(-0.01, "-0.01")

    assert_toml_value(5e+22, "5e+22")

    assert_toml_value(1e6, "1e6")

    %w[1e06 1e+06 1e0_6 1.0e06].each do |float|
      assert_toml_value(1e6, float)
    end

    assert_toml_value(1e-6, "1e-06")

    assert_toml_value(-2E-2, "-2E-2")

    assert_toml_value(6.626e-34, "6.626e-34")

    assert_toml_value(224_617.445_991_228, "224_617.445_991_228")

    assert_toml_value(Float::INFINITY, "inf")

    assert_toml_value(Float::INFINITY, "+inf")

    assert_toml_value(-Float::INFINITY, "-inf")

    assert(value_of("nan").nan?)

    assert(value_of("+nan").nan?)

    assert(value_of("-nan").nan?)
  end

  def test_signed_numbers
    assert_toml_value(26, "+26")

    assert_toml_value(-26, "-26")

    assert_toml_value(1.69, "1.69")

    assert_toml_value(-1.69, "-1.69")
  end

  def test_expressions_with_comments
    assert_equal({"shouldwork" => {}}, TomlRB.parse("[shouldwork] # with comment"))

    parsed = TomlRB.parse("works = true # with comment")
    assert_equal({"works" => true}, parsed)
  end

  def test_array
    assert_equal([], value_of("[]"))

    assert_equal([2, 4], value_of("[ 2, 4]"))

    assert_equal([2.4, 4.72], value_of("[ 2.4, 4.72]"))

    assert_equal([TomlRB::LocalTime.utc(1970, 1, 1, 12), 5], value_of("[12:00:00,5]"))

    assert_equal(%w[hey TomlRB], value_of('[ "hey", "TomlRB"]'))

    assert_equal([%w[hey TomlRB], [2, 4]], value_of('[ ["hey", "TomlRB"], [2,4] ]'))

    assert_equal([{"one" => 1}, {"two" => 2, "three" => 3}], value_of("[ { one = 1 }, { two = 2, three = 3} ]"))
  end

  def test_empty_array
    # test that [] is parsed as array and not as inline table array
    assert_equal({"a" => []}, TomlRB.parse("a = []"))
  end

  def test_multiline_array
    multiline_array = "[ \"hey\",\n   \"ho\",\n\t \"lets\", \"go\",\n ]"
    assert_equal(%w[hey ho lets go], value_of(multiline_array))

    multiline_array = "[\n#1,\n2,\n# 3\n]"
    assert_equal([2], value_of(multiline_array))

    multiline_array = "[\n# comment\n#, more comments\n4]"
    assert_equal([4], value_of(multiline_array))

    multiline_array = "[\n  1,\n  # 2,\n  3 ,\n]"
    assert_equal([1, 3], value_of(multiline_array))

    multiline_array = "[\n  1 , # useless comment\n  # 2,\n  3 #other comment\n]"
    assert_equal([1, 3], value_of(multiline_array))
  end

  # Dates are really hard to test from JSON, due the imposibility to represent
  # datetimes without quotes.
  def test_datetime
    assert_equal(Time.utc(1979, 5, 27, 7, 32, 0), value_of("1979-05-27T07:32:00Z"))

    assert_equal(Time.new(1979, 5, 27, 0, 32, 0, "-07:00"), value_of("1979-05-27T00:32:00-07:00"))

    assert_equal(Time.new(1979, 5, 27, 0, 32, 0.999999r, "-07:00"), value_of("1979-05-27T00:32:00.999999-07:00"))

    assert_equal(Time.utc(1979, 5, 27, 7, 32, 0), value_of("1979-05-27 07:32:00Z"))

    assert_equal(Time.local(1979, 5, 27, 7, 32, 0), value_of("1979-05-27T07:32:00"))

    assert_equal(Time.local(1979, 5, 27, 0, 32, 0, 999999), value_of("1979-05-27T00:32:00.999999"))

    assert_equal(Time.local(1979, 5, 27), value_of("1979-05-27"))

    assert_equal(Time.at(3600 * 7 + 60 * 32), value_of("07:32:00"))

    assert_equal(Time.at(60 * 32, 999999), value_of("00:32:00.999999"))

    assert_equal(Time.new(1979, 5, 27, 7, 32, 0, "-07:00"), value_of("1979-05-27T07:32-07:00"))

    assert_equal(Time.utc(1970, 1, 1, 10, 30, 45), value_of("10:30:45"))

    ["10:30.5", "2025-01-01T10:30.5", "1979-05-27T07:32.5Z", "1979-05-27T07:32.5-07:00"].each do |datetime|
      assert_raises TomlRB::ParseError do
        value_of(datetime)
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
      assert_equal nsec, value_of(datetime).nsec
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
      actual = value_of(datetime)
      assert_equal expected, actual
      assert_instance_of expected.class, actual
    end
  end

  def test_inline_table
    assert_equal({}, value_of("{ }"))

    assert_equal({"simple" => true, "params" => 2}, value_of("{ simple = true, params = 2 }"))

    assert_equal({"nest" => {"really" => {"hard" => true}}}, value_of("{ nest = { really = { hard = true } } }"))
    assert_equal({v: {nest: {really: {hard: true}}}},
      TomlRB.parse("v = { nest = { really = { hard = true } } }", symbolize_keys: true))
  end

  private

  def assert_toml_value(expected, toml)
    actual = value_of(toml)
    assert_equal(expected, actual)
    assert_instance_of(expected.class, actual)
  end

  def value_of(toml)
    TomlRB.parse("v = #{toml}")["v"]
  end

  # Creates all the alternatives of valid indentations to test
  def indentation_alternatives_for(str)
    [str, "  #{str}", "\t#{str}", "\t\t#{str}"].each do |alternative|
      yield(alternative)
    end
  end
end
