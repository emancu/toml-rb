require_relative "helper"

class ParserTest < Test::Unit::TestCase
  def test_text
    text =<<-TOML
        # This is a comment
        # and other comment

        title = "TOML Example"

        # More comments
        # In other lines

        [owners] # A List of owners

          [owners.emancu]
            name = "E. Mancuso"
            age = 26

          [owners.tonchis]
            name = "L. Tolchinsky"
            age = 24

        [version]
        zape = true # wat
    TOML

    hash = {
      "title" => "TOML Example",
      "owners" => {
        "emancu" => {
          "name" => "E. Mancuso",
          "age" => 26
        },
        "tonchis" => {
          "name" => "L. Tolchinsky",
          "age" => 24
        }
      },
      "version" => {
        "zape" => true
      }
    }

    parsed = TOML::Parser.new(text)
    assert_equal hash, parsed.hash
  end

  def test_overwrite_value
    text = <<-TOML
      title = "TOML Example"
      title = "NOT"
    TOML

    assert_raise TOML::ValueOverwriteError do
      TOML::Parser.new(text)
    end
  end
end
