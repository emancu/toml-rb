require_relative "helper"

class EncodingTest < Minitest::Test
  def test_binary_data_raises_parse_error
    binary_data = "\x80\x81\x82".force_encoding("ASCII-8BIT")

    assert_raises(TomlRB::ParseError) do
      TomlRB.parse(binary_data)
    end
  end

  def test_comment_with_high_bytes_raises_parse_error
    # This triggers Encoding::CompatibilityError in Citrus
    # which should be wrapped in TomlRB::ParseError
    data = "# \xFF\xFE comment\nkey = 1".force_encoding("ASCII-8BIT")

    assert_raises(TomlRB::ParseError) do
      TomlRB.parse(data)
    end
  end

  def test_invalid_utf8_sequence_raises_parse_error
    invalid_utf8 = "key = \"\xC3\x28\"".force_encoding("UTF-8")

    error = assert_raises(TomlRB::Error) do
      TomlRB.parse(invalid_utf8)
    end

    assert_match(/encoding/i, error.message)
  end

  def test_valid_ascii_8bit_toml_parses
    valid_ascii = 'key = "value"'.force_encoding("ASCII-8BIT")

    result = TomlRB.parse(valid_ascii)
    assert_equal({"key" => "value"}, result)
  end

  def test_null_bytes_raise_parse_error
    data_with_nulls = "key\x00=\x00value".force_encoding("ASCII-8BIT")

    assert_raises(TomlRB::ParseError) do
      TomlRB.parse(data_with_nulls)
    end
  end
end
