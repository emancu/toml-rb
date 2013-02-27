require_relative "helper"

class ParserTest < Test::Unit::TestCase

  def test_text
    file =<<-TOML
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
        zape = true
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
        "version" => true
      }
    }

    match = Toml.parse file
    assert_equal hash, match.value
  end

end
