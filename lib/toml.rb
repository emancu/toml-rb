require_relative '../init'

module TOML
  # Public: Returns a hash from *TOML* content.
  #
  # content - TOML string to be parsed.
  # options - The Hash options used to refine the parser (default: {}):
  #           :symbolize_keys - true|false (optional).
  #
  #
  # Examples
  #
  #   TOML.parse('[group]')
  #   # => {"group"=>{}}
  #
  #   TOML.parse('title = "TOML parser"')
  #   # => {"title"=>"TOML parser"}
  #
  #   TOML.parse('[group]', symbolize_keys: true)
  #   # => {group: {}}
  #
  #   TOML.parse('title = "TOML parser"', symbolize_keys: true)
  #   # => {title: "TOML parser"}
  #
  #
  # Returns a Ruby hash representation of the content according to TOML spec.
  # Raises ValueOverwriteError if a key is overwritten.
  # Raises ParseError if the content has invalid TOML.
  def self.parse(content, options = {})
    Parser.new(content, options).hash
  end

  # Public: Returns a hash from a *TOML* file.
  #
  # path    - TOML File path
  # options - The Hash options used to refine the parser (default: {}):
  #           :symbolize_keys - true|false (optional).
  #
  #
  # Examples
  #
  #   TOML.load_file('/tmp/simple.toml')
  #   # => {"group"=>{}}
  #
  #   TOML.load_file('/tmp/simple.toml', symbolize_keys: true)
  #   # => {group: {}}
  #
  #
  # Returns a Ruby hash representation of the content.
  # Raises ValueOverwriteError if a key is overwritten.
  # Raises ParseError if the content has invalid TOML.
  # Raises Errno::ENOENT if the file cannot be found.
  # Raises Errno::EACCES if the file cannot be accessed.
  def self.load_file(path, options = {})
    TOML.parse(File.read(path), options)
  end

  # Public: Returns a *TOML* string from a Ruby Hash.
  #
  # hash - Ruby Hash to be dumped into *TOML*
  #
  #
  # Examples
  #
  #   TOML.dump(title: 'TOML dump')
  #   # => "simple = true\n"
  #
  #   hash = {
  #     "title"=>"wow!",
  #     "awesome"=> {
  #       "you"=>true,
  #       "others"=>false
  #     }
  #   }
  #
  #   TOML.dump(hash)
  #   # => "title = \"wow!\"\n[awesome]\nothers = false\nyou = true\n"
  #
  #
  # Returns a TOML string representing the hash.
  def self.dump(hash)
    Dumper.new(hash).toml_str
  end
end
