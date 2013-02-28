require_relative "helper"

class DocumentTest < Test::Unit::TestCase
  def test_keygroup
    indentation_alternatives_for('[akey]') do |str|
      match = Document.parse(str, root: :keygroup)
      assert_equal(TOML::Keygroup, match.value.class)
      assert_equal(['akey'], match.value.instance_variable_get("@nested_keys"))
    end

    match = Document.parse('[owner.emancu]', root: :keygroup)
    assert_equal(['owner', 'emancu'], match.value.instance_variable_get("@nested_keys"))
  end

  def test_keyvalue
    indentation_alternatives_for('key = "value"') do |str|
      match = Document.parse(str, root: :keyvalue)
      assert_equal(TOML::Keyvalue, match.value.class)

      keyvalue = match.value
      assert_equal('key', keyvalue.instance_variable_get("@key"))
      assert_equal('value', keyvalue.instance_variable_get("@value"))
    end
  end

  def test_string
    match = Document.parse('"TOML-Example, should work."', root: :string)
    assert_equal("TOML-Example, should work.", match.value)
  end

  def test_bool
    match = Document.parse('true', root: :bool)
    assert_equal(true, match.value)

    match = Document.parse('false', root: :bool)
    assert_equal(false, match.value)
  end

  def test_integer
    match = Document.parse('26', root: :number)
    assert_equal(26, match.value)
  end

  def test_float
    match = Document.parse('1.69', root: :number)
    assert_equal(1.69, match.value)
  end

  def test_signed_numbers
    match = Document.parse('+26', root: :number)
    assert_equal(26, match.value)

    match = Document.parse('-26', root: :number)
    assert_equal(-26, match.value)

    match = Document.parse('1.69', root: :number)
    assert_equal(1.69, match.value)

    match = Document.parse('-1.69', root: :number)
    assert_equal(-1.69, match.value)
  end

  def test_expressions_with_comments
    match = Document.parse('[shouldwork] # with comment', root: :keygroup)
    assert_equal(['shouldwork'], match.value.instance_variable_get("@nested_keys"))

    match = Document.parse('works = true # with comment', root: :keyvalue).value
    assert_equal("works", match.instance_variable_get("@key"))
    assert_equal(true, match.instance_variable_get("@value"))
  end

  def test_array
    match = Document.parse('[]', root: :array)
    assert_equal([], match.value)

    match = Document.parse('[ 2, 4]', root: :array)
    assert_equal([2,4], match.value)

    match = Document.parse('[ 2.4, 4.72]', root: :array)
    assert_equal([2.4,4.72], match.value)

    match = Document.parse('[ "hey", "TOML"]', root: :array)
    assert_equal(["hey","TOML"], match.value)

    match = Document.parse('[ ["hey", "TOML"], [2,4] ]', root: :array)
    assert_equal([["hey","TOML"], [2,4]], match.value)

    multiline_array = "[ \"hey\",\n   \"ho\",\n\t \"lets\", \"go\",\n ]"
    match = Document.parse(multiline_array, root: :array)
    assert_equal(["hey", "ho", "lets", "go"], match.value)
  end

  def test_datetime
    match = Document.parse('1986-08-28T15:15:00Z', root: :datetime)
    assert_equal(Time.utc(1986,8,28,15,15), match.value)
  end

  private

  # Creates all the alternatives of valid indentations to test
  def indentation_alternatives_for(str)
    [str, "  #{str}", "\t#{str}", "\t\t#{str}"].each do |alternative|
      yield(alternative)
    end
  end
end

