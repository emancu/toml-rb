# encoding: utf-8
require_relative 'helper'

class GrammarTest < Minitest::Test
  def test_comment
    match = TOML::Document.parse(' # A comment', root: :comment)
    assert_equal(nil, match.value)
  end

  def test_key
    match = TOML::Document.parse('bad_key-', root: :key)
    assert_equal('bad_key-', match.value)

    match = TOML::Document.parse('"123.ʎǝʞ.#?"', root: :key)
    assert_equal('123.ʎǝʞ.#?', match.value)
  end

  def test_keygroup
    indentation_alternatives_for('[akey]') do |str|
      match = TOML::Document.parse(str, root: :keygroup)
      assert_equal(TOML::Keygroup, match.value.class)
      assert_equal(['akey'], match.value.instance_variable_get('@nested_keys'))
    end

    match = TOML::Document.parse('[owner.emancu]', root: :keygroup)
    assert_equal(%w(owner emancu),
                 match.value.instance_variable_get('@nested_keys'))

    match = TOML::Document.parse('["owner.emancu"]', root: :keygroup)
    assert_equal(%w(owner.emancu),
                 match.value.instance_variable_get('@nested_keys'))

    match = TOML::Document.parse('["first key"."second key"]', root: :keygroup)
    assert_equal(['first key', 'second key'],
                 match.value.instance_variable_get('@nested_keys'))

    match = TOML::Document.parse('[ owner . emancu ]', root: :keygroup)
    assert_equal(%w(owner emancu),
                 match.value.instance_variable_get('@nested_keys'))

    assert_raises Citrus::ParseError do
      TOML::Document.parse('[ owner emancu ]', root: :keygroup)
    end
  end

  def test_keyvalue
    indentation_alternatives_for('key = "value"') do |str|
      match = TOML::Document.parse(str, root: :keyvalue)
      assert_equal(TOML::Keyvalue, match.value.class)

      keyvalue = match.value
      assert_equal('key', keyvalue.instance_variable_get('@key'))
      assert_equal('value', keyvalue.instance_variable_get('@value'))
    end
  end

  def test_string
    match = TOML::Document.parse('"TOML-Example, should work."', root: :string)
    assert_equal('TOML-Example, should work.', match.value)
  end

  def test_multiline_string
    match = TOML::Document.parse('"""\tOne\nTwo"""', root: :multiline_string)
    assert_equal "\tOne\nTwo", match.value

    to_parse = '"""\
    One \
    Two\
    """'

    match = TOML::Document.parse(to_parse, root: :multiline_string)
    assert_equal "One Two", match.value
  end

  def test_empty_multiline_string
    to_parse = '""""""'

    match = TOML::Document.parse(to_parse, root: :multiline_string)
    assert_equal '', match.value
  end

  def test_special_characters
    match = TOML::Document.parse('"\0 \" \t \n \r"', root: :string)
    assert_equal("\0 \" \t \n \r", match.value)

    match = TOML::Document.parse('"C:\\\\Documents\\\\nada.exe"', root: :string)
    assert_equal('C:\\Documents\\nada.exe', match.value)
  end

  def test_bool
    match = TOML::Document.parse('true', root: :bool)
    assert_equal(true, match.value)

    match = TOML::Document.parse('false', root: :bool)
    assert_equal(false, match.value)
  end

  def test_integer
    match = TOML::Document.parse('26', root: :number)
    assert_equal(26, match.value)

    match = TOML::Document.parse('1_200_000_999', root: :number)
    assert_equal(1_200_000_999, match.value)
  end

  def test_float
    match = TOML::Document.parse('1.69', root: :number)
    assert_equal(1.69, match.value)

    match = TOML::Document.parse('1_000.69', root: :number)
    assert_equal(1000.69, match.value)

    match = TOML::Document.parse('1e6', root: :number)
    assert_equal(1e6, match.value)

    match = TOML::Document.parse('1.02e-46', root: :number)
    assert_equal(1.02e-46, match.value)

    match = TOML::Document.parse('+1e4_000_000', root: :number)
    assert_equal(1e4_000_000, match.value)
  end

  def test_signed_numbers
    match = TOML::Document.parse('+26', root: :number)
    assert_equal(26, match.value)

    match = TOML::Document.parse('-26', root: :number)
    assert_equal(-26, match.value)

    match = TOML::Document.parse('1.69', root: :number)
    assert_equal(1.69, match.value)

    match = TOML::Document.parse('-1.69', root: :number)
    assert_equal(-1.69, match.value)
  end

  def test_expressions_with_comments
    match = TOML::Document.parse('[shouldwork] # with comment', root: :keygroup)
    assert_equal(['shouldwork'],
                 match.value.instance_variable_get('@nested_keys'))

    match = TOML::Document.parse('works = true # with comment', root: :keyvalue).value
    assert_equal('works', match.instance_variable_get('@key'))
    assert_equal(true, match.instance_variable_get('@value'))
  end

  def test_array
    match = TOML::Document.parse('[]', root: :array)
    assert_equal([], match.value)

    match = TOML::Document.parse('[ 2, 4]', root: :array)
    assert_equal([2, 4], match.value)

    match = TOML::Document.parse('[ 2.4, 4.72]', root: :array)
    assert_equal([2.4, 4.72], match.value)

    match = TOML::Document.parse('[ "hey", "TOML"]', root: :array)
    assert_equal(%w(hey TOML), match.value)

    match = TOML::Document.parse('[ ["hey", "TOML"], [2,4] ]', root: :array)
    assert_equal([%w(hey TOML), [2, 4]], match.value)

    match = TOML::Document.parse('[ { one = 1 }, { two = 2, three = 3} ]',
                                 root: :inline_table_array)
    assert_equal([{ 'one' => 1 }, { 'two' => 2, 'three' => 3 }], match.value)
  end

  def test_empty_array
    # test that [] is parsed as array and not as inline table array
    match = TOML::Document.parse("a = []", root: :keyvalue).value
    assert_equal [], match.value
  end

  def test_multiline_array
    multiline_array = "[ \"hey\",\n   \"ho\",\n\t \"lets\", \"go\",\n ]"
    match = TOML::Document.parse(multiline_array, root: :array)
    assert_equal(%w(hey ho lets go), match.value)

    multiline_array = "[\n#1,\n2,\n# 3\n]"
    match = TOML::Document.parse(multiline_array, root: :array)
    assert_equal([2], match.value)

    multiline_array = "[\n# comment\n#, more comments\n4]"
    match = TOML::Document.parse(multiline_array, root: :array)
    assert_equal([4], match.value)

    multiline_array = "[\n  1,\n  # 2,\n  3 ,\n]"
    match = TOML::Document.parse(multiline_array, root: :array)
    assert_equal([1, 3], match.value)

    multiline_array = "[\n  1 , # useless comment\n  # 2,\n  3 #other comment\n]"
    match = TOML::Document.parse(multiline_array, root: :array)
    assert_equal([1, 3], match.value)
  end

  # Dates are really hard to test from JSON, due the imposibility to represent
  # datetimes without quotes.
  def test_datetime
    match = TOML::Document.parse('1986-08-28T15:15:00Z', root: :datetime)
    assert_equal(Time.utc(1986, 8, 28, 15, 15), match.value)

    match = TOML::Document.parse('1986-08-28T15:15:00-03:00', root: :datetime)
    assert_equal(Time.utc(1986, 8, 28, 18, 15), match.value)

    match = TOML::Document.parse('1986-08-28T15:15:00.123-03:00', root: :datetime)
    assert_equal(Time.utc(1986, 8, 28, 18, 15, 0.123), match.value)

    match = TOML::Document.parse('1986-08-28', root: :datetime)
    assert_equal(Time.utc(1986, 8, 28, 0, 0, 0), match.value)

    match = TOML::Document.parse('1986-08-28T15:15:00', root: :datetime)
    assert_equal(Time.utc(1986, 8, 28, 15, 15), match.value)

    match = TOML::Document.parse('1986-08-28T15:15:00.999999', root: :datetime)
    assert_equal(Time.utc(1986, 8, 28, 15, 15, 0.999999), match.value)
  end

  def test_inline_table
    match = TOML::Document.parse('{ }', root: :inline_table)
    assert_equal({}, match.value.value)

    match = TOML::Document.parse('{ simple = true, params = 2 }', root: :inline_table)
    assert_equal({ 'simple' => true, 'params' => 2 }, match.value.value)

    match = TOML::Document.parse('{ nest = { really = { hard = true } } }',
                                 root: :inline_table)
    assert_equal({ 'nest' => { 'really' => { 'hard' => true } } }, match.value.value)
    assert_equal({ nest: { really: { hard: true } } }, match.value.value(true))
  end

  private

  # Creates all the alternatives of valid indentations to test
  def indentation_alternatives_for(str)
    [str, "  #{str}", "\t#{str}", "\t\t#{str}"].each do |alternative|
      yield(alternative)
    end
  end
end
