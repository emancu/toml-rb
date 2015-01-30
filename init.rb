require 'citrus'

ROOT = File.dirname(File.expand_path(__FILE__))

require "#{ROOT}/lib/toml/string"
require "#{ROOT}/lib/toml/array_tables"
require "#{ROOT}/lib/toml/keyvalue"
require "#{ROOT}/lib/toml/keygroup"
require "#{ROOT}/lib/toml/parser"
require "#{ROOT}/lib/toml/dumper"

Citrus.load "#{ROOT}/lib/toml/grammars/helper.citrus"
Citrus.load "#{ROOT}/lib/toml/grammars/primitive.citrus"
Citrus.load "#{ROOT}/lib/toml/grammars/array.citrus"
Citrus.load "#{ROOT}/lib/toml/grammars/document.citrus"
