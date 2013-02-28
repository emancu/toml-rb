Gem::Specification.new do |s|
  s.name        = 'toml-rb'
  s.version     = '0.3'
  s.date        = '2013-02-28'
  s.summary     = "TOML parser in ruby, for ruby."
  s.description = "A TOML parser using Citrus parsing library. Formerly known as 'toml_parser-ruby'. "
  s.authors     = ["Emiliano Mancuso", "Lucas Tolchinsky"]
  s.email       = ['emiliano.mancuso@gmail.com', 'lucas.tolchinsky@gmail.com']
  s.homepage    = 'http://github.com/eMancu/toml-rb'
  s.license     = "MIT"

  s.files = Dir[
    "README.md",
    "Rakefile",
    "lib/**/*.rb",
    "*.gemspec",
    "test/*.*"
  ]

  s.add_dependency "citrus"
end
