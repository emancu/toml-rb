require_relative "helper"
require "tempfile"

class EncodingTest < Minitest::Test
  def test_load_file_uses_utf8
    original_encoding = Encoding.default_external
    Encoding.default_external = Encoding::US_ASCII

    Tempfile.create("toml-encoding") do |file|
      File.binwrite(file.path, "name = \"Jos\u00e9\"\n")

      assert_equal({"name" => "Jos\u00e9"}, TomlRB.load_file(file.path))
      assert_equal({name: "Jos\u00e9"}, TomlRB.load_file(file.path, symbolize_keys: true))

      ["name = \"\xC3\x28\"\n", "# \xFF\xFE comment\nkey = 1"].each do |invalid_toml|
        File.binwrite(file.path, invalid_toml)

        assert_raises(TomlRB::ParseError) do
          TomlRB.load_file(file.path)
        end
      end
    end
  ensure
    Encoding.default_external = original_encoding
  end

  def test_binary_data_raises_parse_error
    binary_data = String.new("\x80\x81\x82", encoding: "ASCII-8BIT")

    assert_raises(TomlRB::ParseError) do
      TomlRB.parse(binary_data)
    end
  end

  def test_comment_with_high_bytes_raises_parse_error
    # This triggers Encoding::CompatibilityError in the parser
    # which should be wrapped in TomlRB::ParseError
    data = String.new("# \xFF\xFE comment\nkey = 1", encoding: "ASCII-8BIT")

    assert_raises(TomlRB::ParseError) do
      TomlRB.parse(data)
    end
  end

  def test_invalid_utf8_sequence_raises_parse_error
    invalid_utf8 = String.new("key = \"\xC3\x28\"", encoding: "UTF-8")

    error = assert_raises(TomlRB::Error) do
      TomlRB.parse(invalid_utf8)
    end

    assert_match(/encoding/i, error.message)
  end

  def test_valid_ascii_8bit_toml_parses
    valid_ascii = String.new('key = "value"', encoding: "ASCII-8BIT")

    result = TomlRB.parse(valid_ascii)
    assert_equal({"key" => "value"}, result)
  end

  def test_null_bytes_raise_parse_error
    data_with_nulls = String.new("key\x00=\x00value", encoding: "ASCII-8BIT")

    assert_raises(TomlRB::ParseError) do
      TomlRB.parse(data_with_nulls)
    end
  end
end
