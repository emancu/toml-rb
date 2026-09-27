# Changelog

## Unreleased

### Breaking changes

- The gem no longer depends on Citrus. The gem has no runtime dependencies.
- `TomlRB.parse` does not use Citrus. A recursive-descent parser on the
  `StringScanner` class of the standard library reads the document, and
  `require "toml-rb"` does not load Citrus. This release removes the grammars
  `TomlRB::Document`, `TomlRB::Primitive` and `TomlRB::Helper`, and the
  modules that the grammars used, like `TomlRB::KeyvalueParser`.
- A value with more than 100 levels of nested arrays and inline tables raises
  `TomlRB::ParseError`. Arrays and inline tables count together. Before,
  toml-rb parsed up to 359 levels on Ruby 3.4.1. More levels raised
  `SystemStackError`, which is not a `TomlRB::Error`.
- A syntax error message gives the line, the column and the expected text.
  Columns count characters, and the first column is 1. For example,
  `[ owner emancu ]` raises `Unexpected "e" at line 1, column 9: expected ']'`.
  Before, the message was `Failed to parse input on line 1 at offset 8`, then
  the line and a caret. Update code that matches the old message.
- When a multi-line string does not end or has an invalid character, the
  message also gives the line and the column where the string starts.
- Errors for invalid values keep their old messages without a line and a
  column, for example `Invalid date: 1979-13-01`.
- For a document with more than one error, `TomlRB.parse` can raise a
  different one of them. The parser reports an invalid value, like
  `1979-13-01` or the escape `\q`, when it reads that value. Before, any
  syntax error in the document came first. In both cases, the error is
  `TomlRB::ParseError`.
- `TomlRB::LocalDateTime` and `TomlRB::LocalDate` values are UTC `Time`
  values, like `TomlRB::LocalTime` values. Their date and clock time match the
  TOML text in every system time zone. `utc?` is true, and `to_s` shows `UTC`.
  The instant of a value moves by the UTC offset of the system time zone at
  that date and time. When this offset is not 0, a parsed value is not equal to
  `Time.local` with the same fields. Build the expected value with `Time.utc`,
  for example `Time.utc(1979, 5, 27, 7, 32)`.
- For parsed local datetimes and dates, `zone` returns `"UTC"`, and
  `utc_offset` returns `0`. `iso8601` output ends in `Z`. YAML output also
  uses UTC. `TomlRB.dump` continues to omit the time zone.

### Fixes

- A document in an encoding other than UTF-8, like BINARY or ISO-8859-1, gives
  the same result with and without a newline at the end. Before, a document
  with non-ASCII bytes and no newline at the end raised `TomlRB::ParseError`.
- A local datetime inside a daylight saving time (DST) gap of the system time
  zone keeps its clock time. For example, `2026-03-29T02:30:00` in
  Europe/Warsaw stays 02:30, and `TomlRB.dump` writes `02:30:00`. Before, it
  became 03:30. A local date keeps the hour 0 when midnight does not occur in
  the system time zone, like 2021-09-05 in America/Santiago. Before, the hour
  was 1.

## v5.0.0.rc.1 (unreleased)

### Breaking changes

- `TomlRB.parse` returns `TomlRB::LocalDateTime`, `TomlRB::LocalDate` and
  `TomlRB::LocalTime` for local datetimes, local dates and local times. Each
  class is a subclass of `Time`. Offset datetimes stay `Time`. For a local
  value, `instance_of?(Time)` and `.class == Time` are false, but
  `is_a?(Time)` and `when Time` match. Use `Time.at(value)` to get a plain
  `Time`, because `value.to_time` returns `value`. (#183)
- A local time is a UTC `Time` on 1970-01-01, at the same instant as before.
  Its `hour`, `min` and `sec` now match the TOML text in every system time
  zone. `to_s`, `zone`, `utc?`, `to_date`, `wday` and `yday` can return other
  values. (#183)
- `TomlRB.dump` writes the UTC offset and the fractional seconds of a `Time` or
  a `DateTime`, with up to 9 digits. Before, it wrote the clock time of the
  value with a `Z` suffix and no fraction. For example,
  `TomlRB.dump(t: Time.now)` now writes the offset of the system time zone
  and up to 9 fractional digits. The dumper removes zeros at the end of the
  fraction, so `Time.at(0, 123456780, :nanosecond).utc` dumps as
  `1970-01-01T00:00:00.12345678Z`. (#183, #193)
- A `Time` built from Float seconds dumps with the binary error of the Float:
  `Time.utc(1979, 5, 27, 7, 32, 0.999999)` dumps as
  `1979-05-27T07:32:00.999998999Z`. Build the `Time` from a Rational to get
  exact digits. (#193)
- `TomlRB.dump` writes a `TomlRB::LocalDateTime` without an offset, a
  `TomlRB::LocalDate` as `YYYY-MM-DD`, and a `TomlRB::LocalTime` as
  `HH:MM:SS`, with a fraction when the value has one. Before, each local value
  dumped as an offset datetime with a `Z` suffix. (#183)
- Offset datetimes keep exact fractional seconds: `.123` gives `nsec`
  123000000, not 122999999. So a parsed value is not equal to a `Time` built
  from Float seconds. Build the expected `Time` from a Rational, for example
  `Rational(123, 1000)`. (#193)
- These documents raise `TomlRB::ParseError` (#199):
  - Integers and floats with leading zeros, like `0123` and `00.5`. Before,
    they parsed as `123` and `0.5`.
  - Dates, times and offsets out of range, like `2025-02-30`, `25:00:00`,
    `07:32:61` and `+24:00`. Before, some values became a later date or time
    (`2025-02-30` became 2025-03-02), and others raised `ArgumentError`.
  - A comma before the fractional seconds, like `07:32:00,5`.
- `a=[12:00:00,5]` is now an array of the local time `12:00:00` and the
  integer `5`. Before, it was an array of one time with the fraction `.5`.
  The document parses in both versions, so no error shows the change. (#199)
- Two statements on one line raise `TomlRB::ParseError`, like `a=1 b=2` and
  `[a] b=2`. An array with a comma and no element, `[,]`, also raises it.
  Before, these documents parsed. (#196)
- These invalid documents parsed before, and now raise
  `TomlRB::ValueOverwriteError` (#197):
  - `"[ab]\n[[a]]\n[ab]"`
  - `"x = false\n[[x]]"`
  - `"a = []\n[[a]]"`
  - `"[a.b]\n[a]\nb = {c = 1}"`
  - A header inside an inline table or a static array, like
    `"a = {b = 1}\n[a.c]"`.
  - A header for a table that dotted keys made, like `"a.b = 1\n[a]"` and
    `"[fruit]\napple.color = \"red\"\n[fruit.apple]"` (toml-lang/toml#859).
  - Dotted keys that extend a table that a header defined, like
    `"[a.b]\n[a]\nb.c=1"` (toml-lang/toml#859).
- These invalid documents raise `TomlRB::ValueOverwriteError` instead of
  another error. `rescue TomlRB::Error` catches `TomlRB::ValueOverwriteError`
  and `TomlRB::ParseError`. (#197)
  - `"a = true\n[[a]]"`: was `NoMethodError`.
  - `"a = 1\n[[a.b]]"` and `"a = 1\na.b = {}"`: was `TypeError`.
  - `"inline-t = {nest = {}}\n[[inline-t.nest]]"`: was `TomlRB::ParseError`.
- Some valid multi-line strings change value. The new value is the value that
  the spec requires (#203):
  - Indentation and blank lines after the opening newline stay.
  - In a multi-line literal string, a backslash at the end of a line stays.
  - `\\` before a newline is an escaped backslash, not a line-ending backslash.
- These strings raise `TomlRB::ParseError` (#203):
  - The escape `\0`, which TOML does not define.
  - A `\u` or `\U` escape that is not a Unicode scalar value: `\uD800` to
    `\uDFFF`, and `\U00110000` and higher.
  - More than two quotes directly before the closing delimiter of a multi-line
    string, like `"""x""""""`.
- Control characters in strings and comments raise `TomlRB::ParseError`:
  U+0000 to U+0008, U+000A to U+001F and U+007F. Tab stays valid, and a
  multi-line string can contain LF and CRLF newlines. (#204)
- `TomlRB.dump` raises `TomlRB::Error` for `nil` and for values without a TOML
  form: Rational, Complex, Set, Struct, other objects, and BigDecimal NaN or
  Infinity. Before, it wrote Ruby `inspect` output, which is not TOML. Remove
  `nil` values before the dump, because TOML has no null. A finite BigDecimal
  dumps as before, like `0.15e1`. (#202)
- `TomlRB.dump` raises `TomlRB::Error` when two keys have the same string form,
  like `"a"` and `:a`. Before, it raised `ArgumentError`. (#202)

### TOML 1.1.0

- Basic and multi-line basic strings accept the `\e` escape for ESC (U+001B).
  The dumper still writes ESC as `\u001B`, which is valid TOML 1.0.0. (#181)
- Basic and multi-line basic strings accept the `\xHH` escape for the code
  point U+00HH, not a byte: `"\xff"` is `"ÿ"`. (#182)
- Seconds are optional in times and datetimes, like `10:30` and
  `1979-05-27T07:32Z`. (#184)
- Fractional seconds can have more than 6 digits. toml-rb keeps 9 digits and
  truncates the rest. (#193)
- Headers and dotted keys follow toml-lang/toml#859. See Breaking changes.
  (#197)
- toml-rb passes all toml-test v2.2.0 decoder tests for TOML 1.1.0. (#180)

### Fixes

- `["a.b"]` and `[a.b]` in one document are two tables. Before, they raised
  `TomlRB::ValueOverwriteError`. (#197)
- `a = {b.c = 1, b.d = 2}` parses. (#197)
- Datetimes accept a lowercase `t` and `z`. (#199)
- A document with only spaces and tabs, and no line break, returns `{}`. (#196)
- An array accepts a comment before a comma. (#196)
- A multi-line basic string accepts spaces and tabs between a line-ending
  backslash and the newline. (#203)
- An escaped quote does not close a multi-line basic string, for example in
  `"""a\""" b"""`. (#203)
- `TomlRB.dump` accepts a hash with String and Symbol keys. (#202)
- `TomlRB.dump` writes a hash inside a mixed or nested array as an inline
  table: `TomlRB.dump(a: [1, {b: 1}])` gives `a = [1, {b = 1}]`. Before, it
  wrote Ruby `inspect` output. For a mixed array with a hash as the first
  element, like `[{b: 1}, 2]`, it raised `NoMethodError`. An array of only
  hashes still dumps as an array of tables (`[[a]]`). (#202)
- `TomlRB.dump` writes a Symbol value as a string and a Regexp with the string
  escapes. Before, it wrote Ruby `inspect` output. (#202)
- `TomlRB.load_file` reads the file as UTF-8. Before, it used the default
  external encoding, and under `LANG=C` it raised `TomlRB::ParseError` for
  non-ASCII text. (#207)
- `symbolize_keys: true` applies to inline tables inside arrays. For a
  document with more than one error, `TomlRB.parse` can raise a different one
  of them. (#209)
- The gem no longer depends on racc. racc is a native extension, and toml-rb
  does not load it. (#205)

### Known limitations

- A local datetime inside a daylight saving time (DST) gap of the system time
  zone changes to a later time. For example, `2026-03-29T02:30:00` in
  Europe/Warsaw becomes 03:30. v4 has the same behavior.
- Psych `YAML.load(YAML.dump(v), permitted_classes: [Time])` and ActiveSupport
  `change` and `advance` return a plain `Time`. So `TomlRB.dump` writes the
  result as an offset datetime.
- `TomlRB.dump` truncates a UTC offset with seconds to whole minutes. For
  example, the local mean time offset `+00:19:32` becomes `+00:19`.
- The TOML 1.0.0 skip-list has 9 tests. toml-rb accepts TOML 1.1.0 syntax and
  has no option to select the spec version, so it does not reject these TOML
  1.0.0 documents.
- Very deep arrays or inline tables raise `SystemStackError`, not a
  `TomlRB::Error`. On Ruby 3.4.1 with the default stack size, 500 nested levels
  raise it.

## v4.2.2 (2026-09-27)

- Security: the regular expressions for strings and comments backtracked in
  exponential or quadratic time. A short document could cause a denial of
  service. The rules now match in linear time. See
  [GHSA-v667-mm43-5q7r](https://github.com/emancu/toml-rb/security/advisories/GHSA-v667-mm43-5q7r).
  (#195)
- Some documents parsed wrongly and now follow the spec: `a="x\"` and
  `a='x\'y'` raise `TomlRB::ParseError`, `a=['C:\', 'D:\']` parses, and
  `a='C:\' # '` gives `"C:\\"` and a comment. (#195)
