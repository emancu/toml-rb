require 'citrus'
require_relative 'toml/keyvalue'
require_relative 'toml/keygroup'
require_relative 'toml/parser'

Citrus.load("toml/grammars/toml")

module TOML
  VERSION = '0.3'

  def self.load(content)
    Parser.new(content).hash
  end

  def self.load_file(path)
    Parser.new((File.read(path)).hash
  end
end
