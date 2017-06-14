require 'citrus'

ROOT = File.dirname(File.expand_path(__FILE__))

require "#{ROOT}/lib/toml-rb/errors"
require "#{ROOT}/lib/toml-rb/array"
require "#{ROOT}/lib/toml-rb/string"
require "#{ROOT}/lib/toml-rb/table_array"
require "#{ROOT}/lib/toml-rb/inline_table"
require "#{ROOT}/lib/toml-rb/keyvalue"
require "#{ROOT}/lib/toml-rb/keygroup"
require "#{ROOT}/lib/toml-rb/parser"
require "#{ROOT}/lib/toml-rb/dumper"

Citrus.load "#{ROOT}/lib/toml-rb/grammars/helper.citrus"
Citrus.load "#{ROOT}/lib/toml-rb/grammars/primitive.citrus"
Citrus.load "#{ROOT}/lib/toml-rb/grammars/array.citrus"
Citrus.load "#{ROOT}/lib/toml-rb/grammars/document.citrus"
