require_relative "helper"

class ErrorsTest < Minitest::Test
  def test_text_after_table
    str = "[error] if you didn't catch this, your parser is broken"
    assert_raises(TomlRB::ParseError) { TomlRB.parse(str) }
  end

  def test_text_after_string
    str = 'string = "Anything other than tabs, spaces and newline after a '
    str += "table or key value pair has ended should produce an error "
    str += 'unless it is a comment" like this'

    assert_raises(TomlRB::ParseError) { TomlRB.parse(str) }
  end

  def test_multiline_array_bad_string
    str = <<-EOS
    array = [
     "This might most likely happen in multiline arrays",
     Like here,
     "or here,
     and here"
     ] End of array comment, forgot the #
    EOS

    assert_raises(TomlRB::ParseError) { TomlRB.parse(str) }
  end

  def test_multiline_array_string_not_ended
    str = <<-EOS
    array = [
     "This might most likely happen in multiline arrays",
     "or here,
     and here"
     ] End of array comment, forgot the #
    EOS

    assert_raises(TomlRB::ParseError) { TomlRB.parse(str) }
  end

  def test_text_after_multiline_array
    str = <<-EOS
    array = [
     "This might most likely happen in multiline arrays",
     "or here",
     "and here"
     ] End of array comment, forgot the #
    EOS

    assert_raises(TomlRB::ParseError) { TomlRB.parse(str) }
  end

  def test_text_after_number
    str = "number = 3.14 pi <--again forgot the #"
    assert_raises(TomlRB::ParseError) { TomlRB.parse(str) }
  end

  def test_numbers_with_leading_zeros
    %w[0123 00 0_0 -01 +01 +0_1 00.5 -03.14 +03.14 01e2 00.5e2].each do |number|
      assert_raises(TomlRB::ParseError) { TomlRB.parse("a = #{number}") }
    end
  end

  def test_invalid_dates
    %w[2025-02-30 2100-02-29 1500-02-29 2025-04-31 2025-13-01 2025-00-01 2025-01-00 2025-01-32].each do |date|
      [date, "#{date}T12:00:00", "#{date}T12:00:00Z"].each do |datetime|
        assert_raises(TomlRB::ParseError) { TomlRB.parse("a = #{datetime}") }
      end
    end
  end

  def test_invalid_times
    %w[24:00:00 00:60:00 00:00:61 12:00:00,5].each do |time|
      [time, "2025-01-01T#{time}", "2025-01-01T#{time}Z"].each do |datetime|
        assert_raises(TomlRB::ParseError) { TomlRB.parse("a = #{datetime}") }
      end
    end
  end

  def test_invalid_offsets
    %w[+24:00 -24:00 +00:60 -00:60].each do |offset|
      assert_raises(TomlRB::ParseError) { TomlRB.parse("a = 2025-01-01T12:00:00#{offset}") }
    end
  end

  def test_value_overwrite
    str = "a = 1\na = 2"
    e = assert_raises(TomlRB::ValueOverwriteError) { TomlRB.parse(str) }
    assert_equal "Key \"a\" is defined more than once", e.message
    assert_equal "a", e.key

    str = "a = false\na = true"
    assert_raises(TomlRB::ValueOverwriteError) { TomlRB.parse(str) }
  end

  def test_table_overwrite
    str = "[a]\nb=1\n[a]\nc=2"
    e = assert_raises(TomlRB::ValueOverwriteError) { TomlRB.parse(str) }
    assert_equal "Key \"a\" is defined more than once", e.message

    str = "[a]\nb=1\n[a]\nb=1"
    e = assert_raises(TomlRB::ValueOverwriteError) { TomlRB.parse(str) }
    assert_equal "Key \"a\" is defined more than once", e.message
  end

  def test_value_overwrite_with_table
    str = "[a]\nb=1\n[a.b]\nc=2"
    e = assert_raises(TomlRB::ValueOverwriteError) { TomlRB.parse(str) }
    assert_equal "Key \"b\" is defined more than once", e.message

    str = "[a]\nb=1\n[a.b.c]\nd=3"
    e = assert_raises(TomlRB::ValueOverwriteError) { TomlRB.parse(str) }
    assert_equal "Key \"b\" is defined more than once", e.message
  end

  def test_table_redefinition
    [
      "[ab]\n[[a]]\n[ab]",
      "x = false\n[[x]]",
      "a = []\n[[a]]",
      "a = [{b = 1}]\n[a.c]",
      "a = {}\n[a.b]",
      "[a.b]\n[a]\nb = {c = 1}",
      "[a.b.c]\nz = 9\n[a]\nb.c.t = 1",
      "[fruit]\napple.color = \"red\"\n[fruit.apple]"
    ].each do |str|
      assert_raises(TomlRB::ValueOverwriteError, str) { TomlRB.parse(str) }
    end
  end

  def test_syntax_error_messages
    {
      "[ owner emancu ]" => %(Unexpected "e" at line 1, column 9: expected ']'),
      "a = 1 b = 2" => %(Unexpected "b" at line 1, column 7: expected a new line),
      "a = [1, 2" => %(Unexpected end of input at line 1, column 10: expected ',' or ']'),
      "\n\nkey = [1,\n  2 3]" => %(Unexpected "3" at line 4, column 5: expected ',' or ']'),
      "a = \"café\" x" => %(Unexpected "x" at line 1, column 12: expected a new line),
      "a = 1\r\nb = " => %(Unexpected end of input at line 2, column 5: expected a value)
    }.each do |toml, message|
      error = assert_raises(TomlRB::ParseError, toml) { TomlRB.parse(toml) }
      assert_equal message, error.message
    end
  end

  def test_multiline_string_errors_name_the_string
    {
      "a = \"\"\"\nfirst\nsecond\n" =>
        %(Unexpected end of input at line 4, column 1: expected '"""' to close the string at line 1, column 5),
      "a = \"\"\"\nok\n\x7F\"\"\"" =>
        %(Unexpected "\\u007F" at line 3, column 1: expected '"""' to close the string at line 1, column 5),
      "a = 1\nb = '''\nok\nx\x01y'''" =>
        %(Unexpected "\\u0001" at line 4, column 2: expected "'''" to close the string at line 2, column 5)
    }.each do |toml, message|
      error = assert_raises(TomlRB::ParseError, toml) { TomlRB.parse(toml) }
      assert_equal message, error.message
    end
  end

  def test_nesting_limit
    assert_nesting_limit
  end

  # Some Ruby runtimes give a thread a smaller stack than the main thread.
  def test_nesting_limit_in_a_thread
    Thread.new { assert_nesting_limit }.join
  end

  private

  def assert_nesting_limit
    [["["], ["{b = "], ["[", "{b = "]].each do |kinds|
      deepest = kinds.cycle.first(100)
      expected = deepest.reverse.reduce(1) { |inner, open| (open == "[") ? [inner] : {"b" => inner} }
      assert_equal({"a" => expected}, TomlRB.parse(nested_toml(deepest)))

      error = assert_raises(TomlRB::ParseError) { TomlRB.parse(nested_toml(kinds.cycle.first(101))) }
      assert_match(/expected at most 100 nested arrays and inline tables\z/, error.message)
    end
  end

  def nested_toml(opens)
    closes = opens.reverse.map { |open| (open == "[") ? "]" : "}" }
    "a = #{opens.join}1#{closes.join}"
  end
end
