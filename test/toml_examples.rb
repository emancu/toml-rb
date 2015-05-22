class TOML::Examples
  def self.example_v_0_4_0
    {
      "table" => {
        "key" => "value",
        "subtable" => {
          "key" => "another value"
        },
        "inline" => {
          "name" => {
            "first" => "Tom",
            "last" => "Preston-Werner"
          },
          "point" => {
            "x" => 1,
            "y" => 2
          }
        }
      },
      "x" => {
        "y" => {
          "z" => {
            "w" => {}
          }
        }
      },
      "string" => {
        "basic" => {
          "basic" => "I'm a string. \"You can quote me\". Name\tJos\\u00E9\nLocation\tSF."
        },
        "multiline" => {
          "key1" => "One\nTwo",
          "key2" => "One\nTwo",
          "key3" => "One\nTwo",
          "continued" => {
            "key1" => "The quick brown fox jumps over the lazy dog.",
            "key2" => "The quick brown fox jumps over the lazy dog.",
            "key3" => "The quick brown fox jumps over the lazy dog."
          }
        },
        "literal" => {
          "winpath" => "C:\\Users\\nodejs\\templates",
          "winpath2" => "\\\\ServerX\\admin$\\system32\\",
          "quoted" => "Tom\"Dubs\"Preston-Werner",
          "regex" => "<\\i\\c*\\s*>",
          "multiline" => {
            "regex2" => "I[
                dw
            ]on'tneed\\d{
                2
            }apples",
            "lines" => "Thefirstnewlineis\ntrimmedinrawstrings.\nAllotherwhitespace\nispreserved.\n"
          }
        }
      },
      "integer" => {
        "key1" => 99,
        "key2" => 42,
        "key3" => 0,
        "key4" => -17,
        "underscores" => {
          "key1" => 1000,
          "key2" => 5349221,
          "key3" => 12345
        }
      },
      "float" => {
        "fractional" => {
          "key1" => 1.0,
          "key2" => 3.1415,
          "key3" => -0.01
        },
        "exponent" => {
          "key1" => 5.0e+22,
          "key2" => 1000000.0,
          "key3" => -0.02
        },
        "both" => {
          "key" => 6.626e-34
        },
        "underscores" => {
          "key1" => 9224617.445991227,
          "key2" => 1e1_000
        }
      },
      "boolean" => {
        "True" => true,
        "False" => false
      },
      "datetime" => {
        "key1" => Time.utc(1979, 05, 27, 07, 32, 0),
        "key2" => Time.new(1979, 05, 27, 00, 32, 0, '-07:00'),
        "key3" => Time.new(1979, 05, 27, 00, 32, 0.999999, '-07:00')
      },
      "array" => {
        "key1" => [1, 2, 3],
        "key2" => %w(red yellow green),
        "key3" => [[1, 2], [3, 4, 5]],
        "key4" => [[1, 2], %w(a b c)],
        "key5" => [1, 2, 3],
        "key6" => [1, 2]
      },
      "products" => [
        { "name" => "Hammer", "sku" => 738594937 },
        {},
        { "name" => "Nail", "sku" => 284758393, "color" => "gray" }
      ],
      "fruit" => [
        {
          "name" => "apple",
          "physical" => {
            "color" => "red",
            "shape" => "round"
          },
          "variety" => [
            { "name" => "red delicious" },
            { "name" => "granny smith" }
          ]
        },
        {
          "name" => "banana",
          "variety" => [
            { "name" => "plantain" }
          ]
        }
      ]
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
      },
      'amqp' => {
        'exchange' => {
          'durable' => true,
          'auto_delete' => false
        }
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
      },
      'parent' => {
        'child1' => { 'key' => 'value' },
        'child2' => [
          { 'key2' => 'value' },
          { 'key3' => 'value' }
        ]
      },
      'a' => {
        'b' => [
          { 'c' => 3 }
        ]
      }
    }
  end
end
