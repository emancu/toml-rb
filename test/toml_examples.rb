class TomlExamples
  def self.example_v_0_3_1
    {
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
          "key" => 6.626e-34
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
      },
      "Datetime" => {
        "key1" => Time.utc(1979, 05, 27, 07, 32, 0),
        "key2" => Time.new(1979, 05, 27, 00, 32, 0, '-07:00'),
        "key3" => Time.new(1979, 05, 27, 00, 32, 0.999999, '-07:00')
      },
      "Array" => {
        "key1" => [1, 2, 3],
        "key2" => %w(red yellow green),
        "key3" => [[1, 2], [3, 4, 5]],
        "key4" => [[1, 2], %w(a b c)],
        "key5" => [1, 2, 3],
        "key6" => [1, 2]
      }
    }
  end

  def self.example
    {
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
  end

  def self.hard_example
    {
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
  end
end
