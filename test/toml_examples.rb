class TomlRB::Examples
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
          "basic" => "I'm a string. \"You can quote me\". Name\tJos\u00E9\nLocation\tSF."
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
          "quoted" => "Tom \"Dubs\" Preston-Werner",
          "regex" => "<\\i\\c*\\s*>",
          "multiline" => {
            "regex2" => "I [dw]on't need \\d{2} apples",
            "lines" => "The first newline is\ntrimmed in raw strings.\n   All other whitespace\n   is preserved.\n"
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

  def self.example_v_0_5_0
    {
      "keys" => {
        "key" => "value",
        "bare_key" => "value",
        "bare-key" => "value",
        "1234" => "value",
        "127.0.0.1" =>"value",
        "character encoding" => "value",
        "ʎǝʞ" => "value",
        'key2' => "value",
        'quoted "value"' => "value",
        "name" => "Orange",
        "physical" => {
          "color" => "orange",
          "shape" => "round"
        },
        'site' => { "google.com" => true },
        "3" => { "14159" => "pi" },
        "a" => {
          "b" => { "c" => 1 },
          "d" => 2,
          "type" => "",
          "name" => "",
          "data" => ""
        },
        "b" => {
          "type" => "",
          "name" => "",
          "data" => ""
        }
      },
      "string" => {
        "str1" => "Roses are red\nViolets are blue",
        "str2" => "Roses are red\nViolets are blue",
        "str3" => "Roses are red\r\nViolets are blue",
        "same" => {
          "str1" => "The quick brown fox jumps over the lazy dog.",
          "str2" => "The quick brown fox jumps over the lazy dog.",
          "str3" => "The quick brown fox jumps over the lazy dog."
        },
        "winpath" => 'C:\\Users\\nodejs\\templates',
        "winpath2" => "\\\\ServerX\\admin$\\system32\\",
        "quoted" => 'Tom "Dubs" Preston-Werner',
        "regex" => '<\\i\\c*\\s*>',
        "regex2" => "I [dw]on't need \\d{2} apples",
        "lines" => "The first newline is\ntrimmed in raw strings.\n   All other whitespace\n   is preserved.\n"
      },
      "integer" => {
        "int1" => +99,
        "int2" => 42,
        "int3" => 0,
        "int4" => -17,
        "int5" => 1000,
        "int6" => 5349221,
        "int7" => 12345,
        "hex1" => 0xDEADBEEF,
        "hex2" => 0xdeadbeef,
        "hex3" => 0xdead_beef,
        "oct1" => 0o01234567,
        "oct2" => 0o755,
        "bin1" => 0b11010110
      },
      "float" => {
        "flt1" => 1.0,
        "flt2" => 3.1415,
        "flt3" => -0.01,
        "flt4" => 5e+22,
        "flt5" => 1e06,
        "flt6" => -2E-2,
        "flt7" => 6.626e-34,
        "flt8" => 224_617.445_991_228,
        "flt9" => -0.0,
        "flt10" => +0.0,
        "sf1" => Float::INFINITY,
        "sf2" => Float::INFINITY,
        "sf3" => -Float::INFINITY,
        "sf4" => Float::NAN,
        "sf5" => Float::NAN,
        "sf6" => Float::NAN
      },
      "boolean" => {
        "bool1" => true,
        "bool2" => false
      },
      "offset-date-time" => {
        "odt1" => Time.new(1979, 5, 27, 7, 32, 0, "+00:00"),
        "odt2" => Time.new(1979, 5, 27, 0, 32, 0, "-07:00"),
        "odt3" => Time.new(1979, 5, 27, 0, 32, 0.999999, "-07:00"),
        "odt4" => Time.new(1979, 5, 27, 7, 32, 0, "+00:00")
      },
      "local-date-time" => {
        "ldt1" => Time.local(1979, 5, 27, 7, 32, 0),
        "ldt2" => Time.local(1979, 5, 27, 0, 32, 0, 999999)
      },
      "local-date" => {
        "ld1" => Time.local(1979, 5, 27)
      },
      "local-time" => {
        "lt1" => Time.at(3600 * 7 + 60 * 32 + 0, 0),
        "lt2" => Time.at(3600 * 0 + 60 * 32 + 0, 999999)
      },
      "array" => {
        "arr1" => [ 1, 2, 3],
        "arr2" => [ "red", "yellow", "green"],
        "arr3" => [[ 1, 2 ], [3, 4, 5]],
        "arr4" => [ "all", "strings", "are the same", "type"],
        "arr5" => [[ 1, 2 ], ["a", "b", "c"]],
        "arr7" => [ 1, 2, 3],
        "arr8" => [ 1, 2]
      },
      "table" => {
        "table-1" => {
          "key1" => "some string",
          "key2" => 123,
        },
        "table-2" => {
          "key1" => "another string",
          "key2" => 456
        },
        "dog" => {
          "tater.man" => {
            "type" => {
              "name" => "pug"
            }
          }
        },
        "a" => {
          "b" => {
            "c" => {}
          },
          "x" => {},
          "y" => {}
        },
        "d" => {
          "e" => {
            "f" => {}
          }
        },
        "g" => {
          "h" => {
            "i" => {}
          }
        },
        "j" => {
          "ʞ" => {
            'l' => {}
          }
        },
        "x" => {
          "y" => {
            "z" => {
              "w" => {}
            }
          }
        },
        "b" => {},
        "fruit" => {
          "apple" => {
            "color" => "red",
            "taste" => {
              "sweet" => true
            },
            "texture" => {
              "smooth" => true
            }
          }
        },
      },
      "inline-table" => {
        "name" => {
          "first" => "Tom",
          "last" => "Preston-Werner"
        },
        "point" => {
          "x" => 1,
          "y" => 2
        },
        "animal" => { 
          "type" => {
            "name" => "pug"
          }
        }
      },
      "array-of-tables" => {
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
    }
  end

  def self.example
    {
      'title' => 'TomlRB Example',
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
      },
      "products" => [
        { "name" => "Hammer", "sku" => 738_594_937 },
        {},
        { "name" => "Nail", "sku" => 284_758_393, "color" => "gray" }
      ]
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
