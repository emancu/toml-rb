task :test do
  require "test/unit"
  require 'citrus'

  Citrus.load '/Users/emancu/Sites/toml_parser-ruby/lib/toml'

  Dir["test/*_test.rb"].each { |file| load file }
end

task :default => :test

