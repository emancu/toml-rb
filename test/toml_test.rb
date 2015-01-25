require_relative 'helper'

class TomlTest < Test::Unit::TestCase
  def test_file_v_0_3_1
    path = File.join(File.dirname(__FILE__), 'example-v0.3.1.toml')
    parsed = TOML.load_file(path)

    hash = {
      'Table' => {
        'key' => 'value'
      },
      'dog' => {
        'tater' => {
          'type' => 'pug'
        }
      },
      'x' => {
        'y' => {
          'z' => {
            'w' => {}
          }
        }
      },
      'String' => {
        'basic' => "I'm a string. \"You can quote me\". Name\tJos\\u00E9\nLocation\tSF.",
        'Multiline' => {
          'key1' => "One\nTwo",
          'key2' => "One\nTwo",
          'key3' => "One\nTwo"
        },
        'Multilined' => {
          'Singleline' => {
            'key1' => 'The quick brown fox jumps over the lazy dog.',
            'key2' => 'The quick brown fox jumps over the lazy dog.',
            'key3' => 'The quick brown fox jumps over the lazy dog.'
          }
        },
        'Literal' => {
          'winpath' => 'C:\\Users\nodejs\templates',
          'winpath2' => "\\\\ServerX\\admin$\\system32\\",
          'quoted' => 'Tom "Dubs" Preston-Werner',
          'regex' => '<\i\c*\s*>',
          'Multiline' => {
            "regex2" => "I [dw]on't need \\d{2} apples",
            "lines" => "The first newline is\ntrimmed in raw strings.\n   All other whitespace\n   is preserved.\n"
          }
        }
      },
      "Integer" => {
        "key1" => 99,
        "key2" => 42,
        "key3" => 0,
        "key4" => -17
      },
      "Float" => {
        "fractional" => {
          "key1" => 1.0,
          "key2" => 3.1415,
          "key3" => -0.01
        },
        "both" => {
          "key"=>6.626e-34
        },
        "exponent" => {
          "key1" => 5.0e+22,
          "key2" => 1000000.0,
          "key3" => -0.02
        }
      },
      "Booleans" => {
        "True" => true,
        "False" => false
      }
    }

    assert_equal hash, parsed
  end

  def test_file
    path = File.join(File.dirname(__FILE__), 'example.toml')
    parsed = TOML.load_file(path)

    hash = {
      'title' => 'TOML Example',

      'owner' => {
        'name' => 'Tom Preston-Werner',
        'organization' => 'GitHub',
        'bio' => "GitHub Cofounder & CEO\nLikes tater tots and beer.",
        'dob' => Time.utc(1979, 05, 27, 07, 32, 00)
      },

      'database' => {
        'server' => '192.168.1.1',
        'ports' => [8001, 8001, 8002],
        'connection_max' => 5000,
        'enabled' => true
      },

      'servers' => {
        'alpha' => {
          'ip' => '10.0.0.1',
          'dc' => 'eqdc10'
        },
        'beta' => {
          'ip' => '10.0.0.2',
          'dc' => 'eqdc10'
        }
      },

      'clients' => {
        'data' => [%w(gamma delta), [1, 2]],
        'hosts' => %w(alpha omega)
      }
    }

    assert_equal hash, parsed
  end

  def test_hard_example
    path = File.join(File.dirname(__FILE__), 'hard_example.toml')
    parsed = TOML.load_file(path)

    hash = {
      'the' => {
        'test_string' => "You'll hate me after this - #",
        'hard' => {
          'test_array'  =>  ['] ', ' # '],
          'test_array2' =>  ['Test #11 ]proved that', 'Experiment #9 was a success'],
          'another_test_string' => ' Same thing, but with a string #',
          'harder_test_string' => " And when \"'s are in the string, along with # \"",
          'bit#' => {
            'what?' => "You don't think some user won't do that?",
            'multi_line_array' => [']']
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
      title: 'TOML Example',

      owner: {
        name: 'Tom Preston-Werner',
        organization: 'GitHub',
        bio: "GitHub Cofounder & CEO\nLikes tater tots and beer.",
        dob: Time.utc(1979, 05, 27, 07, 32, 00)
      },

      database: {
        server: '192.168.1.1',
        ports: [8001, 8001, 8002],
        connection_max: 5000,
        enabled: true
      },

      servers: {
        alpha: {
          ip: '10.0.0.1',
          dc: 'eqdc10'
        },
        beta: {
          ip: '10.0.0.2',
          dc: 'eqdc10'
        }
      },

      clients: {
        data: [%w(gamma delta), [1, 2]],
        hosts: %w(alpha omega)
      }
    }

    assert_equal(hash, parsed)
  end

  def test_line_break
    parsed = TOML.parse("hello = 'world'\r\nline_break = true")
    assert_equal({ 'hello' => 'world', 'line_break' => true }, parsed)
  end
end
