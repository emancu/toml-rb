require 'citrus'
require_relative 'toml/keyvalue'
require_relative 'toml/keygroup'
require_relative 'toml/parser'

Citrus.load(File.dirname(__FILE__) + "/toml/grammars/toml")

module TOML
  VERSION = '0.3'

  def self.load(content)
    Parser.new(content).hash
  end

  def self.parse(path)
    TOML.load(File.read(path))
  end

  def self.load_file(path)
    TOML.parse(path)
  end
end
