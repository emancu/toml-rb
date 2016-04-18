Gem::Specification.new do |s|
  s.name        = 'toml-rb'
  s.version     = '0.3.14'
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.summary     = 'TOML parser in ruby, for ruby.'
  s.description = 'A TOML parser using Citrus parsing library. '
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
    'init.rb'
  ]

  s.add_dependency 'citrus', '~> 3.0', '> 3.0'
end
