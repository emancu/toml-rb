# frozen_string_literal: true

LIBRARIES = [
  ["toml-rb (this checkout)", "toml-rb", nil, "TomlRB", :parse],
  ["toml-rb 5.0.0", "toml-rb", "5.0.0", "TomlRB", :parse],
  ["toml-rb 4.2.2", "toml-rb", "4.2.2", "TomlRB", :parse],
  ["tomlrb 2.0.4", "tomlrb", "2.0.4", "Tomlrb", :parse],
  ["perfect_toml 0.9.1", "perfect_toml", "0.9.1", "PerfectTOML", :parse],
  ["tomlib 0.7.3 (native)", "tomlib", "0.7.3", "Tomlib", :load]
]

SAMPLES = 5
SAMPLE_SECONDS = 0.2

def lock_file(packages)
  toml = +"version = 1\nrequires-python = \">=3.9\"\n"
  packages.times do |i|
    name = "package-#{i}"
    version = "#{i % 5}.#{i % 17}.#{i % 31}"
    url = "https://files.example.org/#{name}-#{version}"
    digest = format("sha256:%064x", i)
    deps = [1, 7, 31].map { |step| "package-#{(i + step) % packages}" }
    toml << <<~TOML

      [[package]]
      name = "#{name}"
      version = "#{version}"
      source = { registry = "https://pypi.org/simple" }
      dependencies = [
          { name = "#{deps[0]}" },
          { name = "#{deps[1]}" },
          { name = "#{deps[2]}", marker = "sys_platform == 'win32'" },
      ]
      sdist = { url = "#{url}.tar.gz", hash = "#{digest}", size = #{i * 37 % 90_000} }
      wheels = [
          { url = "#{url}-cp312-cp312-manylinux_2_17_x86_64.whl", hash = "#{digest}", size = #{i * 41 % 90_000} },
          { url = "#{url}-py3-none-any.whl", hash = "#{digest}", size = #{i * 53 % 90_000} },
      ]

      [package.metadata]
      requires-dist = [
          { name = "#{deps[0]}", specifier = ">=1.0" },
          { name = "#{deps[1]}", specifier = ">=1.0" },
          { name = "#{deps[2]}", marker = "sys_platform == 'win32'", specifier = ">=1.0" },
      ]
    TOML
  end
  toml
end

INPUTS = {
  "example.toml" => File.read(File.expand_path("../test/example.toml", __dir__), encoding: "UTF-8"),
  "100 packages" => lock_file(100),
  "1,000 packages" => lock_file(1_000)
}

def cpu_seconds_per_parse(parse, input, count)
  start = Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID)
  count.times { parse.call(input) }
  (Process.clock_gettime(Process::CLOCK_PROCESS_CPUTIME_ID) - start) / count
end

def median_cpu_seconds(parse, input)
  count = 1
  count *= 2 while cpu_seconds_per_parse(parse, input, count) * count < SAMPLE_SECONDS
  Array.new(SAMPLES) { cpu_seconds_per_parse(parse, input, count) }.sort[SAMPLES / 2]
end

def load_parser(gem_name, version, receiver, method_name)
  if version
    gem gem_name, "= #{version}"
  else
    $LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
  end
  require gem_name
  Object.const_get(receiver).method(method_name)
rescue Gem::MissingSpecError
  nil
end

def child(label, *library)
  parse = load_parser(*library)
  return unless parse

  INPUTS.map do |name, input|
    [parse.call(input), median_cpu_seconds(parse, input)]
  rescue => e
    warn "#{label}, #{name}: #{e.class}: #{e.message}"
    nil
  end
end

def duration(seconds)
  if seconds < 0.001
    format("%.1f µs", seconds * 1_000_000)
  elsif seconds < 1
    format("%.1f ms", seconds * 1000)
  else
    format("%.2f s", seconds)
  end
end

def cell(result, expected)
  return "error" unless result
  return "differs" unless expected && result[0] == expected[0]

  format("%s (%.2fx)", duration(result[1]), result[1] / expected[1])
end

def parent
  puts RUBY_DESCRIPTION, ""
  puts "| Library | #{INPUTS.map { |name, input| format("%s (%.1f KB)", name, input.bytesize / 1024.0) }.join(" | ")} |"
  puts "|---|#{"---:|" * INPUTS.size}"
  reference = nil
  LIBRARIES.each_with_index do |(label, *), index|
    results = Marshal.load(IO.popen([RbConfig.ruby, __FILE__, index.to_s], "rb", &:read))
    reference = results if index.zero?
    cells = results ? results.zip(reference).map { |result, expected| cell(result, expected) } : ["not installed"] * INPUTS.size
    puts "| #{label} | #{cells.join(" | ")} |"
  end
end

if ARGV.empty?
  parent
else
  $stdout.binmode.write(Marshal.dump(child(*LIBRARIES[Integer(ARGV[0])])))
end
