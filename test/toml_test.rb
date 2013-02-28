require_relative 'helper'

class TomlTest < Test::Unit::TestCase
  def test_file
    path = File.join(File.dirname(__FILE__), 'example.toml')
    parsed = TOML::Parser.new(File.read(path))

    hash = {
      "title" => "TOML Example",

      "owner" => {
        "name" => "Tom Preston-Werner",
        "organization" => "GitHub",
        "bio" => "GitHub Cofounder & CEO\nLikes tater tots and beer.",
        "dob" => Time.utc(1979,05,27,07,32,00)
      },

      "databse" => {
        "server" => "192.168.1.1",
        "ports" => [ 8001, 8001, 8002 ],
        "connection_max" => 5000,
        "enabled" => true
      },

      "servers" => {
        "alpha" => {
          "ip" => "10.0.0.1",
          "dc" => "eqdc10"
        },
        "beta" => {
          "ip" => "10.0.0.2",
          "dc" => "eqdc10"
        }
      },

      "clients" => {
        "data" => [["gamma", "delta"], [1, 2]],
        "hosts" => ["alpha", "omega"]
      }
    }

    assert_equal(hash, parsed.hash)
  end
end
