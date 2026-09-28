# Benchmark

`run.rb` compares the CPU time that TOML libraries for Ruby use to parse a document. It compares this checkout with toml-rb 5.0.0, toml-rb 4.2.2, tomlrb, perfect_toml and tomlib.

## What the script measures

- Each library runs in a separate Ruby process, because two versions of one gem cannot load in the same process.
- The script measures only the time to parse a string that is in memory.
- Before the measurement, the script parses each input one time. The table shows "error" if the library cannot parse the input. It shows "differs" if the result is not equal to the result of this checkout.
- The time is the CPU time of the process (`Process::CLOCK_PROCESS_CPUTIME_ID`). The garbage collector stays on.
- The script parses the input 1, 2, 4, 8 or more times in a loop, until the loop takes a minimum of 0.2 seconds. These loops are the warm-up.
- Then the script runs the last loop 5 more times. The table shows the median CPU time to parse the input one time.
- The number in parentheses is the time divided by the time of this checkout. A number below 1 shows a library that is faster than this checkout.

## Inputs

- `example.toml` is `test/example.toml` of this repository (823 bytes).
- `100 packages` (101,467 bytes) and `1,000 packages` (1,027,479 bytes) are lock files that the script generates. Each `[[package]]` table has strings, integers, arrays of inline tables and a `[package.metadata]` table.

The inputs use only TOML 1.0 syntax, because perfect_toml supports only TOML 1.0.

## Libraries

tomlib is a C extension. tomlrb uses the Racc runtime, which runs the parser loop in a C extension. The other libraries are Ruby code.

## Run

```sh
gem install toml-rb:5.0.0 toml-rb:4.2.2 tomlrb:2.0.4 perfect_toml:0.9.1 tomlib:0.7.3
ruby benchmark/run.rb
RUBYOPT=--yjit ruby benchmark/run.rb
```

The table shows "not installed" for a gem that is not installed.
Do not use `bundle exec`. Bundler hides the gems that are not in `Gemfile.lock`.

## Results

The results are from 2026-09-28, on an Apple M3 Pro (5 performance cores and 6 efficiency cores) with macOS 26.5. The rows for this checkout show the parser of toml-rb 6.0.0.

### Ruby 3.4.1

`ruby 3.4.1 (2024-12-25 revision 48d4efcb85) +PRISM [arm64-darwin24]`

| Library | example.toml (0.8 KB) | 100 packages (99.1 KB) | 1,000 packages (1003.4 KB) |
|---|---:|---:|---:|
| toml-rb (this checkout) | 67.2 µs (1.00x) | 5.9 ms (1.00x) | 60.5 ms (1.00x) |
| toml-rb 5.0.0 | 4.5 ms (66.58x) | 506.9 ms (85.74x) | 5.43 s (89.82x) |
| toml-rb 4.2.2 | 4.3 ms (64.57x) | 468.2 ms (79.19x) | 4.97 s (82.22x) |
| tomlrb 2.0.4 | 385.7 µs (5.74x) | 39.8 ms (6.73x) | 384.9 ms (6.36x) |
| perfect_toml 0.9.1 | 67.7 µs (1.01x) | 5.9 ms (1.01x) | 60.2 ms (0.99x) |
| tomlib 0.7.3 (native) | 10.5 µs (0.16x) | 947.3 µs (0.16x) | 9.6 ms (0.16x) |

### Ruby 3.4.1 with YJIT

`ruby 3.4.1 (2024-12-25 revision 48d4efcb85) +YJIT +PRISM [arm64-darwin24]`

| Library | example.toml (0.8 KB) | 100 packages (99.1 KB) | 1,000 packages (1003.4 KB) |
|---|---:|---:|---:|
| toml-rb (this checkout) | 48.6 µs (1.00x) | 4.5 ms (1.00x) | 46.5 ms (1.00x) |
| toml-rb 5.0.0 | 2.9 ms (60.39x) | 412.6 ms (91.88x) | 9.25 s (199.12x) |
| toml-rb 4.2.2 | 3.1 ms (62.84x) | 399.4 ms (88.93x) | 9.44 s (203.11x) |
| tomlrb 2.0.4 | 317.5 µs (6.53x) | 31.7 ms (7.06x) | 318.9 ms (6.86x) |
| perfect_toml 0.9.1 | 54.6 µs (1.12x) | 4.5 ms (1.01x) | 46.4 ms (1.00x) |
| tomlib 0.7.3 (native) | 9.9 µs (0.20x) | 929.3 µs (0.21x) | 9.9 ms (0.21x) |
