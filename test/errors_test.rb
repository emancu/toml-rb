require_relative 'helper'

class ErrorsTest < Test::Unit::TestCase

  def test_text_after_keygroup
    str = "[error] if you didn't catch this, your parser is broken"
    assert_raises(TOML::ParseError){ TOML.parse(str) }
  end

  def test_text_after_string
    str =  'string = "Anything other than tabs, spaces and newline after a '
    str += 'keygroup or key value pair has ended should produce an error '
    str += 'unless it is a comment" like this'

    assert_raises(TOML::ParseError){ TOML.parse(str) }
  end

  def test_multiline_array_bad_string
    str =<<-EOS
    array = [
     "This might most likely happen in multiline arrays",
     Like here,
     "or here,
     and here"
     ] End of array comment, forgot the #
    EOS

    assert_raises(TOML::ParseError){ TOML.parse(str) }
  end

  def test_multiline_array_string_not_ended
    str =<<-EOS
    array = [
     "This might most likely happen in multiline arrays",
     "or here,
     and here"
     ] End of array comment, forgot the #
    EOS

    assert_raises(TOML::ParseError){ TOML.parse(str) }
  end

  def test_text_after_multiline_array
    str =<<-EOS
    array = [
     "This might most likely happen in multiline arrays",
     "or here",
     "and here"
     ] End of array comment, forgot the #
    EOS

    assert_raises(TOML::ParseError){ TOML.parse(str) }
  end

  def test_text_after_number
    str = "number = 3.14 pi <--again forgot the #"
    assert_raises(TOML::ParseError){ TOML.parse(str) }
  end

end
