require_relative "helper"
require_relative "toml_examples"
require "json"

class TomlTest < Minitest::Test
  def test_whitespace_only_document
    assert_equal({}, TomlRB.parse("  \t  "))
  end

  def test_array_comments_before_commas
    parsed = TomlRB.parse("a = [1 # first\n, 2 # last\n,]")
    assert_equal({"a" => [1, 2]}, parsed)
  end

  def test_file_v_0_4_0
    path = File.join(File.dirname(__FILE__), "example-v0.4.0.toml")
    parsed = TomlRB.load_file(path)
    hash = TomlRB::Examples.example_v_0_4_0

    assert_equal hash["array"], parsed["array"]
    assert_equal hash["boolean"], parsed["boolean"]
    assert_equal hash["datetime"], parsed["datetime"]
    assert_equal hash["float"], parsed["float"]
    assert_equal hash["integer"], parsed["integer"]
    assert_equal hash["string"], parsed["string"]
    assert_equal hash["table"], parsed["table"]
    assert_equal hash["products"], parsed["products"]
    assert_equal hash["fruit"], parsed["fruit"]
  end

  def test_file_v_0_5_0
    path = File.join(File.dirname(__FILE__), "example-v0.5.0.toml")
    parsed = TomlRB.load_file(path)
    hash = TomlRB::Examples.example_v_0_5_0
    assert_equal hash["keys"], parsed["keys"]
    assert_equal hash["string"], parsed["string"]
    assert_equal hash["integer"], parsed["integer"]
    assert_equal hash["float"], parsed["float"]
    assert_equal hash["boolean"], parsed["boolean"]
    assert_equal hash["offset-date-time"], parsed["offset-date-time"]
    assert_equal hash["local-date-time"], parsed["local-date-time"]
    assert_equal hash["local-date"], parsed["local-date"]
    assert_equal hash["local-time"], parsed["local-time"]
    assert_equal hash["array"], parsed["array"]
    assert_equal hash["table"], parsed["table"]
    assert_equal hash["inline-table"], parsed["inline-table"]
    assert_equal hash["array-of-tables"], parsed["array-of-tables"]
  end

  def test_file
    path = File.join(File.dirname(__FILE__), "example.toml")
    parsed = TomlRB.load_file(path)

    assert_equal TomlRB::Examples.example, parsed
  end

  def test_hard_example
    path = File.join(File.dirname(__FILE__), "hard_example.toml")
    parsed = TomlRB.load_file(path)

    assert_equal TomlRB::Examples.hard_example, parsed
  end

  def test_symbolize_keys
    path = File.join(File.dirname(__FILE__), "example.toml")
    parsed = TomlRB.load_file(path, symbolize_keys: true)

    hash = {
      title: "TomlRB Example",

      owner: {
        name: "Tom Preston-Werner",
        organization: "GitHub",
        bio: "GitHub Cofounder & CEO\nLikes tater tots and beer.",
        dob: Time.utc(1979, 0o5, 27, 0o7, 32, 0o0)
      },

      database: {
        server: "192.168.1.1",
        ports: [8001, 8001, 8002],
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
        data: [%w[gamma delta], [1, 2]],
        hosts: %w[alpha omega]
      },

      amqp: {
        exchange: {
          durable: true,
          auto_delete: false
        }
      },

      products: [
        {name: "Hammer", sku: 738_594_937},
        {},
        {name: "Nail", sku: 284_758_393, color: "gray"}
      ]

    }

    assert_equal(hash, parsed)
  end

  def test_datetime_classes
    parsed = TomlRB.parse("odt = 1979-05-27T07:32:00Z\nldt = 1979-05-27T07:32:00\nld = 1979-05-27\nlt = 07:32:00")

    assert_instance_of Time, parsed["odt"]
    assert_instance_of TomlRB::LocalDateTime, parsed["ldt"]
    assert_instance_of TomlRB::LocalDate, parsed["ld"]
    assert_instance_of TomlRB::LocalTime, parsed["lt"]

    parsed = TomlRB.parse("odt = 1979-05-27T07:32Z\nldt = 2025-01-01T10:30\nlt = 10:30")

    assert_instance_of Time, parsed["odt"]
    assert_instance_of TomlRB::LocalDateTime, parsed["ldt"]
    assert_instance_of TomlRB::LocalTime, parsed["lt"]
    assert_equal Time.utc(1979, 5, 27, 7, 32, 0), parsed["odt"]
    assert_equal Time.local(2025, 1, 1, 10, 30, 0), parsed["ldt"]
    assert_equal Time.utc(1970, 1, 1, 10, 30, 0), parsed["lt"]
  end

  def test_line_break
    parsed = TomlRB.parse("hello = 'world'\r\nline_break = true")
    assert_equal({"hello" => "world", "line_break" => true}, parsed)
  end

  def test_comments_do_not_affect_table_structure
    parsed = TomlRB.parse("# [x]\nroot = 1\n[x]\nvalue = 2")
    assert_equal({"root" => 1, "x" => {"value" => 2}}, parsed)

    parsed = TomlRB.parse("# [[x]]\nroot = 1\n[[x]]\nvalue = 2")
    assert_equal({"root" => 1, "x" => [{"value" => 2}]}, parsed)

    parsed = TomlRB.parse("#[a.b]\nroot = 1\n[a.b]\nvalue = 2")
    assert_equal({"root" => 1, "a" => {"b" => {"value" => 2}}}, parsed)

    parsed = TomlRB.parse("[a] # [b]\nvalue = 1\n[b]\nvalue = 2")
    assert_equal({"a" => {"value" => 1}, "b" => {"value" => 2}}, parsed)
  end

  def test_trailing_whitespace_after_keyvalue
    parsed = TomlRB.parse("a = 1   ")
    assert_equal({"a" => 1}, parsed)
  end

  def test_trailing_whitespace_after_line_break
    parsed = TomlRB.parse("[table]\r\na = 1\r\n  ")
    assert_equal({"table" => {"a" => 1}}, parsed)
  end

  def test_tables_and_dotted_keys
    parsed = TomlRB.parse("[\"a.b\"]\nx = 1\n[a.b]\nx = 2")
    assert_equal({"a.b" => {"x" => 1}, "a" => {"b" => {"x" => 2}}}, parsed)

    parsed = TomlRB.parse("a = {b.c = 1, b.d = 2}")
    assert_equal({"a" => {"b" => {"c" => 1, "d" => 2}}}, parsed)

    parsed = TomlRB.parse("[fruit]\napple.color = \"red\"\n[fruit.apple.texture]\nsmooth = true")
    assert_equal({"fruit" => {"apple" => {"color" => "red", "texture" => {"smooth" => true}}}}, parsed)

    parsed = TomlRB.parse("[a.b.c]\n[a]\nb.d = 1")
    assert_equal({"a" => {"b" => {"c" => {}, "d" => 1}}}, parsed)
  end

  def test_valid_cases
    Dir["test/examples/valid/**/*.json"].each do |json_file|
      toml_file = File.join(File.dirname(json_file),
        File.basename(json_file, ".json")) + ".toml"
      begin
        toml = TomlRB.load_file(toml_file)
      rescue TomlRB::Error => e
        assert false, "Error: #{e} in #{toml_file}"
      end

      json = JSON.parse(File.read(json_file))

      assert_equal json, toml, "In file '#{toml_file}'"
    end
  end

  def test_invalid_cases
    Dir["test/examples/invalid/**/*.toml"].each do |toml_file|
      assert_raises(TomlRB::Error, "For file #{toml_file}") do
        TomlRB.load_file(toml_file)
      end
    end
  end
end
