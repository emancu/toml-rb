require_relative 'helper'

class DumperTest < Test::Unit::TestCase
  def test_dump_empty
    dumped = TOML.dump({})
    assert_equal('', dumped)
  end

  def test_dump_types
    dumped = TOML.dump(string: 'TOML "dump"')
    assert_equal("string = \"TOML \\\"dump\\\"\"\n", dumped)

    dumped = TOML.dump(float: -13.24)
    assert_equal("float = -13.24\n", dumped)

    dumped = TOML.dump(int: 1234)
    assert_equal("int = 1234\n", dumped)

    dumped = TOML.dump(true: true)
    assert_equal("true = true\n", dumped)

    dumped = TOML.dump(false: false)
    assert_equal("false = false\n", dumped)

    dumped = TOML.dump(array: [1, 2, 3])
    assert_equal("array = [1, 2, 3]\n", dumped)

    dumped = TOML.dump(array: [[1, 2], %w(weird one)])
    assert_equal("array = [[1, 2], [\"weird\", \"one\"]]\n", dumped)

    dumped = TOML.dump(datetime: Time.utc(1986, 8, 28, 15, 15))
    assert_equal("datetime = 1986-08-28T15:15:00Z\n", dumped)
  end

  def test_dump_nested_attributes
    hash = { nested: { hash: { deep: true } } }
    dumped = TOML.dump(hash)
    assert_equal("[nested.hash]\ndeep = true\n", dumped)

    hash[:nested].merge!(other: 12)
    dumped = TOML.dump(hash)
    assert_equal("[nested]\nother = 12\n[nested.hash]\ndeep = true\n", dumped)

    hash[:nested].merge!(nest: { again: 'it never ends' })
    dumped = TOML.dump(hash)
    toml = <<-EOS.gsub(/^ {6}/, '')
      [nested]
      other = 12
      [nested.hash]
      deep = true
      [nested.nest]
      again = "it never ends"
    EOS

    assert_equal(toml, dumped)
  end
end
