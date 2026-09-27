# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "toml-rb/version"

Gem::Specification.new do |s|
  s.name = "toml-rb"
  s.version = TomlRB::VERSION
  s.summary = "Toml parser in ruby, for ruby."
  s.description = "A TOML 1.1.0 parser and dumper."
  s.authors = ["Emiliano Mancuso", "Lucas Tolchinsky"]
  s.email = ["emiliano.mancuso@gmail.com", "lucas.tolchinsky@gmail.com"]
  s.homepage = "https://github.com/emancu/toml-rb"
  s.license = "MIT"

  s.files = Dir[
    "README.md",
    "lib/**/*.rb",
    "LICENSE"
  ]

  s.required_ruby_version = ">= 2.5"

  s.add_development_dependency "minitest", "~> 5.7"
  s.add_development_dependency "standard", "~> 1.4"
  s.add_development_dependency "rake"
end
