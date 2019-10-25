# encoding: utf-8
require_relative 'helper'

class GrammarTest < Minitest::Test
  def test_comment
    match = TomlRB::Document.parse(' # A comment', root: :comment)
    assert_nil(match.value)
  end

  def test_key
    match = TomlRB::Document.parse('bad_key-', root: :key)
    assert_equal('bad_key-', match.value.first)

    match = TomlRB::Document.parse('"123.ʎǝʞ.#?"', root: :key)
    assert_equal('123.ʎǝʞ.#?', match.value.first)
  end

  def test_table
    indentation_alternatives_for('[akey]') do |str|
      match = TomlRB::Document.parse(str, root: :table)
      assert_equal(TomlRB::Table, match.value.class)
      assert_equal(['akey'], match.value.instance_variable_get('@dotted_keys'))
    end

    match = TomlRB::Document.parse('[owner.emancu]', root: :table)
    assert_equal(%w(owner emancu),
                 match.value.instance_variable_get('@dotted_keys'))

    match = TomlRB::Document.parse('["owner.emancu"]', root: :table)
    assert_equal(%w(owner.emancu),
                 match.value.instance_variable_get('@dotted_keys'))

    match = TomlRB::Document.parse('["first key"."second key"]', root: :table)
    assert_equal(['first key', 'second key'],
                 match.value.instance_variable_get('@dotted_keys'))

    match = TomlRB::Document.parse('[ owner . emancu ]', root: :table)
    assert_equal(%w(owner emancu),
                 match.value.instance_variable_get('@dotted_keys'))

    assert_raises Citrus::ParseError do
      TomlRB::Document.parse('[ owner emancu ]', root: :table)
    end
  end

  def test_keyvalue
    indentation_alternatives_for('key = "value"') do |str|
      match = TomlRB::Document.parse(str, root: :keyvalue)
      assert_equal(TomlRB::Keyvalue, match.value.class)

      keyvalue = match.value
      assert_equal('key', keyvalue.instance_variable_get('@dotted_keys').first)
      assert_equal('value', keyvalue.instance_variable_get('@value'))
    end

    indentation_alternatives_for('key1."key2".key3 = "value"') do |str|
      match = TomlRB::Document.parse(str, root: :keyvalue)
      assert_equal(TomlRB::Keyvalue, match.value.class)

      keyvalue = match.value
      assert_equal('key1', keyvalue.instance_variable_get('@dotted_keys')[0])
      assert_equal('key2', keyvalue.instance_variable_get('@dotted_keys')[1])
      assert_equal('key3', keyvalue.instance_variable_get('@dotted_keys')[2])
      assert_equal('value', keyvalue.instance_variable_get('@value'))
    end
  end

  def test_string
    match = TomlRB::Document.parse('"TomlRB-Example, should work."', root: :string)
    assert_equal('TomlRB-Example, should work.', match.value)
  end

  def test_multiline_string
    match = TomlRB::Document.parse('"""\tOne\nTwo"""', root: :multiline_string)
    assert_equal "\tOne\nTwo", match.value

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
    assert_equal '', match.value
  end

  def test_special_characters
    match = TomlRB::Document.parse('"\0 \" \t \n \r"', root: :string)
    assert_equal("\0 \" \t \n \r", match.value)

    match = TomlRB::Document.parse('"C:\\\\Documents\\\\nada.exe"', root: :string)
    assert_equal('C:\\Documents\\nada.exe', match.value)
  end

  def test_bool
    match = TomlRB::Document.parse('true', root: :bool)
    assert_equal(true, match.value)

    match = TomlRB::Document.parse('false', root: :bool)
    assert_equal(false, match.value)
  end

  def test_integer
    match = TomlRB::Document.parse('+99', root: :integer)
    assert_equal(99, match.value)

    match = TomlRB::Document.parse('42', root: :integer)
    assert_equal(42, match.value)

    match = TomlRB::Document.parse('0', root: :integer)
    assert_equal(0, match.value)

    match = TomlRB::Document.parse('-17', root: :integer)
    assert_equal(-17, match.value)

    match = TomlRB::Document.parse('1_000', root: :integer)
    assert_equal(1_000, match.value)

    match = TomlRB::Document.parse('5_349_221', root: :integer)
    assert_equal(5_349_221, match.value)

    match = TomlRB::Document.parse('1_2_3_4_5', root: :integer)
    assert_equal(1_2_3_4_5, match.value)

    match = TomlRB::Document.parse('0xDEADBEEF', root: :integer)
    assert_equal(0xDEADBEEF, match.value)

    match = TomlRB::Document.parse('0xdeadbeef', root: :integer)
    assert_equal(0xdeadbeef, match.value)

    match = TomlRB::Document.parse('0xdead_beef', root: :integer)
    assert_equal(0xdead_beef, match.value)

    match = TomlRB::Document.parse('0o01234567', root: :integer)
    assert_equal(0o01234567, match.value)

    match = TomlRB::Document.parse('0o755', root: :integer)
    assert_equal(0o755, match.value)

    match = TomlRB::Document.parse('0b11010110', root: :integer)
    assert_equal(0b11010110, match.value)
  end

  def test_float
    match = TomlRB::Document.parse('+1.0', root: :float)
    assert_equal(+1.0, match.value)

    match = TomlRB::Document.parse('3.1415', root: :float)
    assert_equal(3.1415, match.value)

    match = TomlRB::Document.parse('-0.01', root: :float)
    assert_equal(-0.01, match.value)

    match = TomlRB::Document.parse('5e+22', root: :float)
    assert_equal(5e+22, match.value)

    match = TomlRB::Document.parse('1e6', root: :float)
    assert_equal(1e6, match.value)

    match = TomlRB::Document.parse('-2E-2', root: :float)
    assert_equal(-2E-2, match.value)

    match = TomlRB::Document.parse('6.626e-34', root: :float)
    assert_equal(6.626e-34, match.value)

    match = TomlRB::Document.parse('224_617.445_991_228', root: :float)
    assert_equal(224_617.445_991_228, match.value)

    match = TomlRB::Document.parse('inf', root: :float)
    assert_equal(Float::INFINITY, match.value)

    match = TomlRB::Document.parse('+inf', root: :float)
    assert_equal(Float::INFINITY, match.value)

    match = TomlRB::Document.parse('-inf', root: :float)
    assert_equal(-Float::INFINITY, match.value)

    match = TomlRB::Document.parse('nan', root: :float)
    assert(match.value.nan?)

    match = TomlRB::Document.parse('+nan', root: :float)
    assert(match.value.nan?)

    match = TomlRB::Document.parse('-nan', root: :float)
    assert(match.value.nan?)
  end

  def test_signed_numbers
    match = TomlRB::Document.parse('+26', root: :number)
    assert_equal(26, match.value)

    match = TomlRB::Document.parse('-26', root: :number)
    assert_equal(-26, match.value)

    match = TomlRB::Document.parse('1.69', root: :number)
    assert_equal(1.69, match.value)

    match = TomlRB::Document.parse('-1.69', root: :number)
    assert_equal(-1.69, match.value)
  end

  def test_expressions_with_comments
    match = TomlRB::Document.parse('[shouldwork] # with comment', root: :table)
    assert_equal(['shouldwork'],
                 match.value.instance_variable_get('@dotted_keys'))

    match = TomlRB::Document.parse('works = true # with comment', root: :keyvalue).value
    assert_equal('works', match.instance_variable_get('@dotted_keys').first)
    assert_equal(true, match.instance_variable_get('@value'))
  end

  def test_array
    match = TomlRB::Document.parse('[]', root: :array)
    assert_equal([], match.value)

    match = TomlRB::Document.parse('[ 2, 4]', root: :array)
    assert_equal([2, 4], match.value)

    match = TomlRB::Document.parse('[ 2.4, 4.72]', root: :array)
    assert_equal([2.4, 4.72], match.value)

    match = TomlRB::Document.parse('[ "hey", "TomlRB"]', root: :array)
    assert_equal(%w(hey TomlRB), match.value)

    match = TomlRB::Document.parse('[ ["hey", "TomlRB"], [2,4] ]', root: :array)
    assert_equal([%w(hey TomlRB), [2, 4]], match.value)

    match = TomlRB::Document.parse('[ { one = 1 }, { two = 2, three = 3} ]',
                                   root: :array)
    assert_equal([{ 'one' => 1 }, { 'two' => 2, 'three' => 3 }], match.value)
  end

  def test_empty_array
    # test that [] is parsed as array and not as inline table array
    match = TomlRB::Document.parse("a = []", root: :keyvalue).value
    assert_equal [], match.value
  end

  def test_multiline_array
    multiline_array = "[ \"hey\",\n   \"ho\",\n\t \"lets\", \"go\",\n ]"
    match = TomlRB::Document.parse(multiline_array, root: :array)
    assert_equal(%w(hey ho lets go), match.value)

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
    match = TomlRB::Document.parse('1979-05-27T07:32:00Z', root: :datetime)
    assert_equal(Time.utc(1979, 5, 27, 7, 32, 0), match.value)

    match = TomlRB::Document.parse('1979-05-27T00:32:00-07:00', root: :datetime)
    assert_equal(Time.new(1979, 5, 27, 0, 32, 0, '-07:00'), match.value)

    match = TomlRB::Document.parse('1979-05-27T00:32:00.999999-07:00', root: :datetime)
    assert_equal(Time.new(1979, 5, 27, 0, 32, 0.999999, '-07:00'), match.value)
    
    match = TomlRB::Document.parse('1979-05-27 07:32:00Z', root: :datetime)
    assert_equal(Time.utc(1979, 5, 27, 7, 32, 0), match.value)

    match = TomlRB::Document.parse('1979-05-27T07:32:00', root: :datetime)
    assert_equal(Time.local(1979, 5, 27, 7, 32, 0), match.value)

    match = TomlRB::Document.parse('1979-05-27T00:32:00.999999', root: :datetime)
    assert_equal(Time.local(1979, 5, 27, 0, 32, 0, 999999), match.value)

    match = TomlRB::Document.parse('1979-05-27', root: :datetime)
    assert_equal(Time.local(1979, 5, 27), match.value)

    match = TomlRB::Document.parse('07:32:00', root: :datetime)
    assert_equal(Time.at(3600 * 7 + 60 * 32), match.value)

    match = TomlRB::Document.parse('00:32:00.999999', root: :datetime)
    assert_equal(Time.at(60 * 32, 999999), match.value)
  end

  def test_inline_table
    match = TomlRB::Document.parse('{ }', root: :inline_table)
    assert_equal({}, match.value.value)

    match = TomlRB::Document.parse('{ simple = true, params = 2 }', root: :inline_table)
    assert_equal({ 'simple' => true, 'params' => 2 }, match.value.value)

    match = TomlRB::Document.parse('{ nest = { really = { hard = true } } }',
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
