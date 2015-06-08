require_relative 'helper'
require_relative 'toml_examples'
require 'json'

class TomlTest < Minitest::Test
  def test_file_v_0_4_0
    path = File.join(File.dirname(__FILE__), 'example-v0.4.0.toml')
    parsed = TOML.load_file(path)
    hash = TOML::Examples.example_v_0_4_0

    assert_equal hash['Array'], parsed['Array']
    assert_equal hash['Booleans'], parsed['Booleans']
    assert_equal hash['Datetime'], parsed['Datetime']
    assert_equal hash['Float'], parsed['Float']
    assert_equal hash['Integer'], parsed['Integer']
    assert_equal hash['String'], parsed['String']
    assert_equal hash['Table'], parsed['Table']
    assert_equal hash['products'], parsed['products']
    assert_equal hash['fruit'], parsed['fruit']
  end

  def test_file
    path = File.join(File.dirname(__FILE__), 'example.toml')
    parsed = TOML.load_file(path)

    assert_equal TOML::Examples.example, parsed
  end

  def test_hard_example
    path = File.join(File.dirname(__FILE__), 'hard_example.toml')
    parsed = TOML.load_file(path)

    assert_equal TOML::Examples.hard_example, parsed
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
      },

      amqp: {
        exchange: {
          durable: true,
          auto_delete: false
        }
      }
    }

    assert_equal(hash, parsed)
  end

  def test_line_break
    parsed = TOML.parse("hello = 'world'\r\nline_break = true")
    assert_equal({ 'hello' => 'world', 'line_break' => true }, parsed)
  end

  def compare_toml_files(folder, file = nil, &block)
    file ||= '*'
    Dir["test/examples/#{folder}/#{file}.json"].each do |json_file|
      toml_file = File.join(File.dirname(json_file),
                            File.basename(json_file, '.json')) + '.toml'
      begin
        toml = TOML.load_file(toml_file)
      rescue TOML::Error => e
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
      assert_raises(TOML::Error, "For file #{toml_file}") do
        TOML.load_file(toml_file)
      end
    end
  end
end
