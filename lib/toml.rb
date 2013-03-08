require_relative "../init"

module TOML
  def self.parse(content, options = {})
    Parser.new(content, options).hash
  end

  def self.load_file(path, options = {})
    TOML.parse(File.read(path), options)
  end
end
