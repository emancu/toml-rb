require "test/unit"
require 'citrus'
require_relative '../lib/toml/keyvalue'
require_relative '../lib/toml/keygroup'
require_relative '../lib/toml/parser'

Citrus.load(File.dirname(__FILE__) + "/../lib/toml/grammars/primitive.citrus")
Citrus.load(File.dirname(__FILE__) + "/../lib/toml/grammars/array.citrus")
Citrus.load(File.dirname(__FILE__) + "/../lib/toml/grammars/document.citrus")

