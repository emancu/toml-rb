require_relative 'helper'
require_relative 'toml_examples'
require 'json'

class TomlTest < Minitest::Test
  def test_file_v_0_4_0
    path = File.join(File.dirname(__FILE__), 'example-v0.4.0.toml')
    parsed = TomlRB.load_file(path)
    hash = TomlRB::Examples.example_v_0_4_0

    assert_equal hash['array'], parsed['array']
    assert_equal hash['boolean'], parsed['boolean']
    assert_equal hash['datetime'], parsed['datetime']
    assert_equal hash['float'], parsed['float']
    assert_equal hash['integer'], parsed['integer']
    assert_equal hash['string'], parsed['string']
    assert_equal hash['table'], parsed['table']
    assert_equal hash['products'], parsed['products']
    assert_equal hash['fruit'], parsed['fruit']
  end

  def test_file_v_0_5_0
    path = File.join(File.dirname(__FILE__), 'example-v0.5.0.toml')
    parsed = TomlRB.load_file(path)
    hash = TomlRB::Examples.example_v_0_5_0
    assert_equal hash['keys'], parsed['keys']
    assert_equal hash['string'], parsed['string']
    assert_equal hash['integer'], parsed['integer']
    assert_equal hash['float'], parsed['float']
    assert_equal hash['boolean'], parsed['boolean']
    assert_equal hash['offset-date-time'], parsed['offset-date-time']
    assert_equal hash['local-date-time'], parsed['local-date-time']
    assert_equal hash['local-date'], parsed['local-date']
    assert_equal hash['local-time'], parsed['local-time']
    assert_equal hash['array'], parsed['array']
    assert_equal hash['table'], parsed['table']
    assert_equal hash['inline-table'], parsed['inline-table']
    assert_equal hash['array-of-tables'], parsed['array-of-tables']
  end

  def test_file
    path = File.join(File.dirname(__FILE__), 'example.toml')
    parsed = TomlRB.load_file(path)

    assert_equal TomlRB::Examples.example, parsed
  end

  def test_hard_example
    path = File.join(File.dirname(__FILE__), 'hard_example.toml')
    parsed = TomlRB.load_file(path)

    assert_equal TomlRB::Examples.hard_example, parsed
  end

  def test_symbolize_keys
    path = File.join(File.dirname(__FILE__), 'example.toml')
    parsed = TomlRB.load_file(path, symbolize_keys: true)

    hash = {
      title: 'TomlRB Example',

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
      },

      amqp: {
        exchange: {
          durable: true,
          auto_delete: false
        }
      },

      products: [
        { name: "Hammer", sku: 738_594_937 },
        {},
        { name: "Nail", sku: 284_758_393, color: "gray" }
      ]

    }

    assert_equal(hash, parsed)
  end

  def test_line_break
    parsed = TomlRB.parse("hello = 'world'\r\nline_break = true")
    assert_equal({ 'hello' => 'world', 'line_break' => true }, parsed)
  end

  def compare_toml_files(folder, file = nil, &block)
    file ||= '*'
    Dir["test/examples/#{folder}/#{file}.json"].each do |json_file|
      toml_file = File.join(File.dirname(json_file),
                            File.basename(json_file, '.json')) + '.toml'
      begin
        toml = TomlRB.load_file(toml_file)
      rescue TomlRB::Error => e
        assert false, "Error: #{e} in #{toml_file}"
      end
      json = JSON.parse(File.read(json_file))
      block.call(json, toml, toml_file)
    end
  end

  def test_valid_cases
    compare_toml_files 'valid' do |json, toml, file|
      assert_equal json, toml, "In file '#{file}'"
    end
  end

  def test_invalid_cases
    file = '*'
    Dir["test/examples/invalid/#{file}.toml"].each do |toml_file|
      assert_raises(TomlRB::Error, "For file #{toml_file}") do
        TomlRB.load_file(toml_file)
      end
    end
  end
end
