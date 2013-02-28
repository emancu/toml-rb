Gem::Specification.new do |s|
  s.name        = 'toml_parser-ruby'
  s.version     = '0.3'
  s.date        = '2013-02-24'
  s.summary     = "TOML parser in ruby, for ruby."
  s.description = "A TOML parser using Citrus parsing library"
  s.authors     = ["Emiliano Mancuso"]
  s.email       = 'emiliano.mancuso@gmail.com'
  s.homepage    = 'http://github.com/eMancu/toml_parser-ruby'
  s.license     = "MIT"

  s.files = Dir[
    "README.md",
    "Rakefile",
    "lib/**/*.rb",
    "*.gemspec",
    "test/*.*"
  ]

  s.add_dependency "citrus"


  s.post_install_message = <<-MESSAGE
  !    The 'toml_parser-ruby' gem has been deprecated and has been replaced by 'toml-rb'.
  !    See: https://rubygems.org/gems/toml-rb
  !    And: https://github.com/eMancu/toml-rb
  MESSAGE
end
