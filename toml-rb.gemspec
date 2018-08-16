Gem::Specification.new do |s|
  s.name        = 'toml-rb'
  s.version     = '1.1.2'
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.summary     = 'Toml parser in ruby, for ruby.'
  s.description = 'A Toml parser using Citrus parsing library. '
  s.authors     = ['Emiliano Mancuso', 'Lucas Tolchinsky']
  s.email       = ['emiliano.mancuso@gmail.com', 'lucas.tolchinsky@gmail.com']
  s.homepage    = 'http://github.com/emancu/toml-rb'
  s.license     = 'MIT'

  s.files = Dir[
    'README.md',
    'Rakefile',
    'lib/**/*.rb',
    'lib/**/*.citrus',
    '*.gemspec',
    'test/*.*',
  ]

  s.required_ruby_version = '>= 1.9'
  s.add_dependency 'citrus', '~> 3.0', '> 3.0'
end
