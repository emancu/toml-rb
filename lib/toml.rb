require_relative "../init"

module TOML
  VERSION = '0.3'

  def self.load(content, symbolize_keys = false)
    Parser.new(content, symbolize_keys).hash
  end

  def self.parse(path, symbolize_keys = false)
    TOML.load(File.read(path), symbolize_keys)
  end

  def self.load_file(path, symbolize_keys = false)
    TOML.parse(path, symbolize_keys)
  end
end
