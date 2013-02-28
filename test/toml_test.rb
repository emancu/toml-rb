require_relative "helper"

class DocumentTest < Test::Unit::TestCase
  def test_keygroup
    indentation_alternatives_for('[akey]') do |str|
      match = Document.parse(str, root: :keygroup).value
      assert_equal(['akey'], match.nested_keys)
    end

    match = Document.parse("[owner.emancu]", root: :keygroup).value
    assert_equal(['owner', 'emancu'], match.nested_keys)
  end

  def test_keyvalue_string
    indentation_alternatives_for('title = "TOML-Example, should work."') do |str|
      match = Document.parse(str, root: :keyvalue).value
      assert_equal("title", match.key)
      assert_equal("TOML-Example, should work.", match.value)
    end
  end

  def test_keyvalue_bool
    indentation_alternatives_for('enabled = true') do |str|
      match = Document.parse(str, root: :keyvalue).value
      assert_equal("enabled", match.key)
      assert_equal(true, match.value)
    end
  end

  def test_keyvalue_integer
    indentation_alternatives_for('age = 26') do |str|
      match = Document.parse(str, root: :keyvalue).value
      assert_equal("age", match.key)
      assert_equal(26, match.value)
    end
  end

  def test_keyvalue_float
    indentation_alternatives_for('height = 1.69') do |str|
      match = Document.parse(str, root: :keyvalue).value
      assert_equal("height", match.key)
      assert_equal(1.69, match.value)
    end
  end

  def test_keyvalue_signed_numbers
    match = Document.parse('age = +26', root: :keyvalue).value
    assert_equal("age", match.key)
    assert_equal(26, match.value)

    match = Document.parse('age = -26', root: :keyvalue).value
    assert_equal(-26, match.value)

    match = Document.parse('height = 1.69', root: :keyvalue).value
    assert_equal(1.69, match.value)

    match = Document.parse('height = -1.69', root: :keyvalue).value
    assert_equal(-1.69, match.value)
  end

  def test_expressions_with_comments
    match = Document.parse('[shouldwork] # with comment', root: :keygroup).value
    assert_equal(['shouldwork'], match.nested_keys)

    match = Document.parse('works = true # with comment', root: :keyvalue).value
    assert_equal("works", match.key)
    assert_equal(true, match.value)
  end

  def test_array
    match = Document.parse('array = []', root: :keyvalue).value
    assert_equal("array", match.key)
    assert_equal([], match.value)

    match = Document.parse('array = [ 2, 4]', root: :keyvalue).value
    assert_equal([2,4], match.value)

    match = Document.parse('array = [ 2.4, 4.72]', root: :keyvalue).value
    assert_equal([2.4,4.72], match.value)

    match = Document.parse('array = [ "hey", "TOML"]', root: :keyvalue).value
    assert_equal(["hey","TOML"], match.value)

    match = Document.parse('array = [ ["hey", "TOML"], [2,4] ]', root: :keyvalue).value
    assert_equal([["hey","TOML"], [2,4]], match.value)

    multiline_array = <<-EOS
      array = [
        "hey", "ho",
        "lets",
        "go",
      ]
    EOS
    match = Document.parse(multiline_array, root: :keyvalue).value
    assert_equal(["hey", "ho", "lets", "go"], match.value)
  end

  def test_datetime
    match = Document.parse('dob = 1986-08-28T15:15:00Z', root: :keyvalue).value
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

