# Changelog

## Unreleased

- `dump` raises `TomlRB::Error` for more than 100 nested tables and arrays,
  counted together below the root hash, instead of `SystemStackError` for
  deeply nested or cyclic values. Parsing dotted keys and headers is
  unchanged. (#219)

## v6.0.0 (2026-09-28)

### Breaking changes

- toml-rb has no runtime dependencies. A parser on the `StringScanner` class
  replaces Citrus, and `require "toml-rb"` does not load Citrus. (#212, #213)
- This release removes the Citrus grammars `TomlRB::Document`,
  `TomlRB::Primitive` and `TomlRB::Helper`, and their modules, like
  `TomlRB::KeyvalueParser`. (#212)
- More than 100 nested levels of arrays and inline tables, counted together,
  raise `TomlRB::ParseError`. Before, up to 359 levels parsed on Ruby 3.4.1,
  and more levels raised `SystemStackError`. (#212)
- Syntax errors give the line, the column and the expected text, like
  `Unexpected "e" at line 1, column 9: expected ']'`. Update code that matches
  the old message. Errors for invalid values, like `Invalid date: 1979-13-01`,
  do not change. (#212)
- When a multi-line string has no end or has an invalid character, the error
  also gives the line and the column where the string starts. (#212)
- `parse` reports an invalid value, like `1979-13-01`, when it reads the value.
  Before, any syntax error in the document came first. (#212)
- `TomlRB::LocalDateTime` and `TomlRB::LocalDate` are UTC `Time` values, like
  `TomlRB::LocalTime`. `utc?` is true, `utc_offset` is 0, and `to_s`, `zone`,
  `iso8601` and YAML show UTC. The instant moves by the system UTC offset.
  Compare with `Time.utc`. `dump` still writes no time zone. (#214)

### Fixes

- A local datetime in a daylight saving time (DST) gap of the system time zone
  keeps its clock time: `2026-03-29T02:30:00` in Europe/Warsaw stays 02:30, not
  03:30. A local date keeps the hour 0 when the zone skips midnight. (#214)
- A document in an encoding other than UTF-8, like BINARY, gives the same
  result with and without a newline at the end. (#212)
- `dump` time grows in proportion to the output size. Before, it grew with the
  square of the size, and a 3.3 MB lock file took 45 times longer. (#218)

## v5.0.0 (2026-09-28)

### Breaking changes

- `parse` returns `TomlRB::LocalDateTime`, `TomlRB::LocalDate` and
  `TomlRB::LocalTime` for local values. Each is a `Time` subclass: `is_a?(Time)`
  stays true and `instance_of?(Time)` is false. Offset datetimes stay `Time`.
  Use `Time.at(value)` for a plain `Time`. (#183)
- A local time is a UTC `Time` on 1970-01-01, at the same instant as in v4.
  `hour`, `min` and `sec` match the TOML text in all zones. `to_s`, `zone` and
  `utc?` can change. (#183)
- `dump` writes local values without offsets: `1979-05-27`, `07:32:00` or
  `1979-05-27T07:32:00`. Before, it wrote datetimes with `Z`. (#183)
- `dump` writes the UTC offset of a `Time` or `DateTime` and up to 9 fractional
  digits, with no final zeros. Before, it wrote the clock time with `Z` and no
  fraction. (#183, #193)
- `parse` keeps exact fractions: `.123` gives `nsec` 123000000. A `Time` built
  from Float seconds is not equal, and dumps with the Float error. Build the
  `Time` from a Rational. (#193)
- Leading zeros, out-of-range dates, times and offsets, comma fractions, `[,]`
  and two statements per line raise `TomlRB::ParseError`. (#196, #199)
- `a=[12:00:00,5]` now has two elements: a local time and an integer. (#199)
- Duplicate tables or tables that headers and dotted keys both extend now raise
  `TomlRB::ValueOverwriteError` (toml-lang/toml#859). Some parsed before. (#197)
- Invalid input raises `TomlRB::Error` or a subclass instead of `NoMethodError`,
  `TypeError` or `ArgumentError`. Use `rescue TomlRB::Error`. (#197, #199, #202)
- Some valid multi-line strings change value to match the spec. Indentation
  and blank lines after the first newline stay. Multi-line literal strings keep
  backslashes at line ends. `\\` before a newline escapes a backslash. (#203)
- The escape `\0`, invalid `\u` and `\U` code points, and more than two quotes
  before a multi-line end delimiter raise `TomlRB::ParseError`. (#203)
- Control characters in strings and comments raise `TomlRB::ParseError`. Tabs
  stay valid. Multi-line strings accept LF and CRLF newlines. (#204)
- `dump` raises `TomlRB::Error` for `nil`, Rational, Complex, Set, Struct, other
  objects and non-finite BigDecimal. Before, it wrote Ruby `inspect` output.
  Remove `nil` values before `dump`. (#202)
- `symbolize_keys: true` also applies to inline tables inside arrays:
  `a = [{b = 1}]` gives `{a: [{b: 1}]}`. Before, `b` stayed a String key.
  `parse` can raise a different error for a document with many errors. (#209)

### TOML 1.1.0

- Basic strings accept `\e` for ESC. `dump` still writes `\u001B`. (#181)
- Basic strings accept `\xHH` code points, not bytes (`"\xff"` is `"ÿ"`). (#182)
- Seconds are optional in times and datetimes. (#184)
- Fractions can exceed 6 digits. toml-rb keeps 9 and truncates the rest. (#193)
- toml-rb passes all toml-test v2.2.0 decoder tests for TOML 1.1.0. (#180)

### Fixes

- `["a.b"]` and `[a.b]` define separate tables. (#197)
- Inline tables accept shared dotted key prefixes. (#197)
- Datetimes accept lowercase `t` and `z`. (#199)
- Spaces and tabs alone give `{}`. Arrays accept comments before commas. (#196)
- Multi-line basic strings accept spaces and tabs after a final backslash.
  Escaped quotes do not close these strings. (#203)
- `dump` accepts a hash with String and Symbol keys. Two keys with the same
  string form, like `"a"` and `:a`, raise `TomlRB::Error`. (#202)
- `dump` writes Symbol values as strings and Regexp with string escapes. (#202)
- `dump` uses inline tables for hashes in mixed or nested arrays. (#202)
- `load_file` reads files as UTF-8, also under `LANG=C`. (#207)
- The gem no longer depends on racc. (#205)

### Known limitations

- In the system time zone, a DST gap moves local datetimes later, as in v4.
- A YAML round trip or ActiveSupport `change` and `advance` turn a local value
  into a plain `Time`, so `dump` writes an offset datetime.
- `dump` truncates UTC offsets with seconds to whole minutes.
- toml-rb always accepts TOML 1.1.0 syntax. No option selects TOML 1.0.0, so 9
  toml-test 1.0.0 tests that expect an error do not pass.
- Deep arrays or inline tables raise `SystemStackError`, not `TomlRB::Error`.

## v4.2.2 (2026-09-27)

- Security: the regular expressions for strings and comments backtracked in
  exponential or quadratic time. A short document could cause a denial of
  service. The rules now match in linear time. See
  [GHSA-v667-mm43-5q7r](https://github.com/emancu/toml-rb/security/advisories/GHSA-v667-mm43-5q7r).
  (#195)
- Some documents parsed wrongly and now follow the spec: `a="x\"` and
  `a='x\'y'` raise `TomlRB::ParseError`, `a=['C:\', 'D:\']` parses, and
  `a='C:\' # '` gives `"C:\\"` and a comment. (#195)
