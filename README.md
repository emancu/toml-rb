toml-rb
=======

Formerly known as __toml_parser-ruby__.

A [TOML](https://github.com/mojombo/toml) parser using [Citrus](http://mjijackson.com/citrus/example.html) library.


Installation
------------

    $ gem install toml-rb

Usage
-----

```ruby
require 'toml'

# From a file!
path = File.join(File.dirname(__FILE__), 'path', 'to', 'file')
TOML.load_file(path)

# From a stream!
stream = <<-EOS
  title = "wow!"

  [awesome]
    you    = true
    others = false
EOS
TOML.parse(stream)

# You want symbols as your keys? No problem!
TOML.load_file(path, symbolize_keys: true) 
# Works the same for TOML.parse
```

Contributing
------------

1. Fork it
2. Bundle it `$ dep install` (install [dep](https://github.com/cyx/dep) if you don't have it)
3. Create your feature branch `git checkout -b my-new-feature`
4. Add tests and commit your changes `git commit -am 'Add some feature'`
5. Run tests `$ rake`
6. Push the branch `git push origin my-new-feature`
7. Create new Pull Request

License
-------

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
