class TomlTest < Test::Unit::TestCase
  def test_comment
    match = Toml.parse('# This is a comment', :root => :comment)
    assert(match)
    assert_equal('# This is a comment', match)
  end

  def test_keygroup
    match = Toml.parse('[akey]', :root => :keygroup)
    assert(match)
    assert_equal('[akey]', match)
    assert_equal('akey', match.value)
  end

  def test_keyvalue_string
    match = Toml.parse('title = "TOML Example"', :root => :keyvalue)
    assert(match)
    assert_equal('title = "TOML Example"', match)
    assert_equal('title', match.key)
    assert_equal('TOML Example', match.val)
    assert_equal({"title" => "TOML Example"}, match.value)
  end

  def test_keyvalue_bool
    match = Toml.parse('enabled = true', :root => :keyvalue)
    assert(match)
    assert_equal('enabled = true', match)
    assert_equal('enabled', match.key)
    assert_equal(true, match.val)
    assert_equal({"enabled" => true}, match.value)
  end

  def test_keyvalue_integer
    match = Toml.parse('age = 26', :root => :keyvalue)
    assert(match)
    assert_equal('age = 26', match)
    assert_equal('age', match.key)
    assert_equal(26, match.val)
    assert_equal({"age" => 26}, match.value)
  end

  def test_keyvalue_float
    match = Toml.parse('height = 1.69', :root => :keyvalue)
    assert(match)
    assert_equal('height = 1.69', match)
    assert_equal('height', match.key)
    assert_equal(1.69, match.val)
    assert_equal({"height" => 1.69}, match.value)
  end

  def test_keyvalue_signed_numbers
    match = Toml.parse('age = +26', :root => :keyvalue)
    assert_equal(26, match.val)
    match = Toml.parse('age = -26', :root => :keyvalue)
    assert_equal(-26, match.val)
    match = Toml.parse('height = +1.69', :root => :keyvalue)
    assert_equal(1.69, match.val)
    match = Toml.parse('height = -1.69', :root => :keyvalue)
    assert_equal(-1.69, match.val)
  end

end

