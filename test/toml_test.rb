require_relative 'helper'

class TomlTest < Test::Unit::TestCase
  def test_file
    path = File.join(File.dirname(__FILE__), 'example.toml')
    parsed = TOML.load_file(path)

    hash = {
      "title" => "TOML Example",

      "owner" => {
        "name" => "Tom Preston-Werner",
        "organization" => "GitHub",
        "bio" => "GitHub Cofounder & CEO\nLikes tater tots and beer.",
        "dob" => Time.utc(1979,05,27,07,32,00)
      },

      "database" => {
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

    assert_equal(hash, parsed)
  end

  def test_hard_example
    path = File.join(File.dirname(__FILE__), 'hard_example.toml')
    parsed = TOML.load_file(path)

    hash = {
      "the" => {
        "test_string" => "You'll hate me after this - #",
        "hard" => {
          "test_array"  =>  [ "] ", " # "],
          "test_array2" =>  [ "Test #11 ]proved that", "Experiment #9 was a success" ],
          "another_test_string" => " Same thing, but with a string #",
          "harder_test_string" => " And when \"'s are in the string, along with # \"",
          "bit#" => {
            "what?" => "You don't think some user won't do that?",
            "multi_line_array" => [ "]" ]
          }
        }
      }
    }

    assert_equal(hash, parsed)
  end

  def test_symbolize_keys
    path = File.join(File.dirname(__FILE__), 'example.toml')
    parsed = TOML.load_file(path, symbolize_keys: true)

    hash = {
      title: "TOML Example",

      owner: {
        name: "Tom Preston-Werner",
        organization: "GitHub",
        bio: "GitHub Cofounder & CEO\nLikes tater tots and beer.",
        dob: Time.utc(1979,05,27,07,32,00)
      },

      database: {
        server: "192.168.1.1",
        ports: [ 8001, 8001, 8002 ],
        connection_max: 5000,
        enabled: true
      },

      servers: {
        alpha: {
          ip: "10.0.0.1",
          dc: "eqdc10"
        },
        beta: {
          ip: "10.0.0.2",
          dc: "eqdc10"
        }
      },

      clients: {
        data: [["gamma", "delta"], [1, 2]],
        hosts: ["alpha", "omega"]
      }
    }

    assert_equal(hash, parsed)
  end
end
