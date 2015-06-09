require_relative 'helper'

class ErrorsTest < Minitest::Test
  def test_text_after_keygroup
    str = "[error] if you didn't catch this, your parser is broken"
    assert_raises(TOML::ParseError) { TOML.parse(str) }
  end

  def test_text_after_string
    str = 'string = "Anything other than tabs, spaces and newline after a '
    str += 'keygroup or key value pair has ended should produce an error '
    str += 'unless it is a comment" like this'

    assert_raises(TOML::ParseError) { TOML.parse(str) }
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

    assert_raises(TOML::ParseError) { TOML.parse(str) }
  end

  def test_multiline_array_string_not_ended
    str = <<-EOS
    array = [
     "This might most likely happen in multiline arrays",
     "or here,
     and here"
     ] End of array comment, forgot the #
    EOS

    assert_raises(TOML::ParseError) { TOML.parse(str) }
  end

  def test_text_after_multiline_array
    str = <<-EOS
    array = [
     "This might most likely happen in multiline arrays",
     "or here",
     "and here"
     ] End of array comment, forgot the #
    EOS

    assert_raises(TOML::ParseError) { TOML.parse(str) }
  end

  def test_text_after_number
    str = 'number = 3.14 pi <--again forgot the #'
    assert_raises(TOML::ParseError) { TOML.parse(str) }
  end

  def test_value_overwrite
    str = "a = 1\na = 2"
    e = assert_raises(TOML::ValueOverwriteError) { TOML.parse(str) }
    assert_equal "Key \"a\" is defined more than once", e.message
    assert_equal "a", e.key

    str = "a = false\na = true"
    assert_raises(TOML::ValueOverwriteError) { TOML.parse(str) }
  end

  def test_table_overwrite
    str = "[a]\nb=1\n[a]\nc=2"
    e = assert_raises(TOML::ValueOverwriteError) { TOML.parse(str) }
    assert_equal "Key \"a\" is defined more than once", e.message

    str = "[a]\nb=1\n[a]\nb=1"
    e = assert_raises(TOML::ValueOverwriteError) { TOML.parse(str) }
    assert_equal "Key \"a\" is defined more than once", e.message
  end

  def test_value_overwrite_with_table
    str = "[a]\nb=1\n[a.b]\nc=2"
    e = assert_raises(TOML::ValueOverwriteError) { TOML.parse(str) }
    assert_equal "Key \"b\" is defined more than once", e.message

    str = "[a]\nb=1\n[a.b.c]\nd=3"
    e = assert_raises(TOML::ValueOverwriteError) { TOML.parse(str) }
    assert_equal "Key \"b\" is defined more than once", e.message
  end
end
