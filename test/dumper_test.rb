require_relative "helper"
require "date"

class DumperTest < Minitest::Test
  def test_dump_empty
    dumped = TomlRB.dump({})
    assert_equal("", dumped)
  end

  def test_dump_types
    dumped = TomlRB.dump(string: 'TomlRB "dump"')
    assert_equal("string = \"TomlRB \\\"dump\\\"\"\n", dumped)

    dumped = TomlRB.dump(float: -13.24)
    assert_equal("float = -13.24\n", dumped)

    dumped = TomlRB.dump(int: 1234)
    assert_equal("int = 1234\n", dumped)

    dumped = TomlRB.dump(truthy: true)
    assert_equal("truthy = true\n", dumped)

    dumped = TomlRB.dump(falsey: false)
    assert_equal("falsey = false\n", dumped)

    dumped = TomlRB.dump(array: [1, 2, 3])
    assert_equal("array = [1, 2, 3]\n", dumped)

    dumped = TomlRB.dump(array: [[1, 2], %w[weird one]])
    assert_equal("array = [[1, 2], [\"weird\", \"one\"]]\n", dumped)

    dumped = TomlRB.dump(array: %w[#$ #@ #{}])
    assert_equal("array = [\"\#$\", \"\#@\", \"\#{}\"]\n", dumped)

    dumped = TomlRB.dump(time: Time.utc(1986, 8, 28, 15, 15))
    assert_equal("time = 1986-08-28T15:15:00Z\n", dumped)

    dumped = TomlRB.dump(datetime: DateTime.new(1986, 8, 28, 15, 15))
    assert_equal("datetime = 1986-08-28T15:15:00Z\n", dumped)

    dumped = TomlRB.dump(date: Date.new(1986, 8, 28))
    assert_equal("date = 1986-08-28\n", dumped)

    dumped = TomlRB.dump(regexp: /abc\n*\{/)
    assert_equal("regexp = \"/abc\\\\n*\\\\{/\"\n", dumped)
  end

  def test_dump_nested_attributes
    hash = {nested: {hash: {deep: true}}}
    dumped = TomlRB.dump(hash)
    assert_equal("[nested.hash]\ndeep = true\n", dumped)

    hash[:nested][:other] = 12
    dumped = TomlRB.dump(hash)
    assert_equal("[nested]\nother = 12\n[nested.hash]\ndeep = true\n", dumped)

    hash[:nested][:nest] = {again: "it never ends"}
    dumped = TomlRB.dump(hash)
    toml = <<-EOS.gsub(/^ {6}/, "")
      [nested]
      other = 12
      [nested.hash]
      deep = true
      [nested.nest]
      again = "it never ends"
    EOS

    assert_equal(toml, dumped)

    hash = {non: {'bare."keys"' => {"works" => true}}}
    dumped = TomlRB.dump(hash)
    assert_equal("[non.\"bare.\\\"keys\\\"\"]\nworks = true\n", dumped)

    hash = {hola: [{chau: 4}, {chau: 3}]}
    dumped = TomlRB.dump(hash)
    assert_equal("[[hola]]\nchau = 4\n[[hola]]\nchau = 3\n", dumped)
  end

  def test_print_empty_tables
    hash = {plugins: {cpu: {foo: "bar", baz: 1234}, disk: {}, io: {}}}
    dumped = TomlRB.dump(hash)
    toml = <<-EOS.gsub(/^ {6}/, "")
      [plugins.cpu]
      baz = 1234
      foo = "bar"
      [plugins.disk]
      [plugins.io]
    EOS

    assert_equal toml, dumped
  end

  def test_dump_array_tables
    hash = {fruit: [{physical: {color: "red"}}, {physical: {color: "blue"}}]}
    dumped = TomlRB.dump(hash)
    toml = <<-EOS.gsub(/^ {6}/, "")
      [[fruit]]
      [fruit.physical]
      color = "red"
      [[fruit]]
      [fruit.physical]
      color = "blue"
    EOS

    assert_equal toml, dumped
  end

  def test_dump_interpolation_curly
    hash = {"key" => "includes \#{variable}"}
    dumped = TomlRB.dump(hash)

    assert_equal %(key = "includes \#{variable}") + "\n", dumped
  end

  def test_dump_interpolation_at
    hash = {"key" => 'includes #@variable'}
    dumped = TomlRB.dump(hash)

    assert_equal 'key = "includes #@variable"' + "\n", dumped
  end

  def test_dump_interpolation_dollar
    hash = {"key" => 'includes #$variable'}
    dumped = TomlRB.dump(hash)

    assert_equal 'key = "includes #$variable"' + "\n", dumped
  end

  def test_dump_special_chars_in_literals
    hash = {'\t' => "escape special chars in string literals"}
    dumped = TomlRB.dump(hash)

    assert_equal %("\\t" = "escape special chars in string literals") + "\n", dumped
  end

  def test_dump_special_chars_in_strings
    hash = {"\t" => "escape special chars in strings"}
    dumped = TomlRB.dump(hash)

    assert_equal %("\t" = "escape special chars in strings") + "\n", dumped
  end
end
