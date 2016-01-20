#!/usr/bin/env ruby

require 'closure-compiler'
require 'defacer'
require 'uglifier'
require 'terminal-table'
require 'zlib'

puts <<-MANIFESTO

Defacer's goal is to be faster than any other javascript minification
gem while producing output that is no more than 5% larger than any
other gem, after gzipping the output of each.

This script tests Defacer against the Closure compiler gem using
several popular javascript libraries to determine whether or not we
are meeting that goal. The benchmarks are running now and will take a
few seconds.

MANIFESTO

def percent_difference(baseline, measured, labels)
  value = (measured.to_f - baseline.to_f) / baseline.to_f
  label = (value < 0) ? labels.first : labels.last
  rounded = (value.abs * 100).to_i
  "#{rounded}% #{label}"
end

def benchmark_minifier(name, js_file, &block)
  basename = js_file.split('/').last
  input = File.read(js_file)

  start_time = Time.now.to_f
  minified = block.call(input)
  gzipped_size = Zlib::Deflate.deflate(minified).size
  elapsed = ((Time.now.to_f - start_time) * 1000).to_i

  File.open("benchmark-outputs/#{name}-#{basename}", 'w') { |f| f.write(minified) }

  return gzipped_size, elapsed
end

defacer = Defacer
closure = Closure::Compiler.new

rows = [[
          'script',
          'size: closure + gz',
          'size: defacer + gz',
          'size',
          'speed: closure + gz',
          'speed: defacer + gz',
          'speed',
        ]]

rows << :separator


Dir['spec/fixtures/benchmarks/*.js'].each do |js_file|
  basename = js_file.split('/').last

  row = []
  row << basename

  closure_gzipped_size, closure_elapsed = benchmark_minifier('closure', js_file) { |i| closure.compile(i) }
  defacer_gzipped_size, defacer_elapsed = benchmark_minifier('defacer', js_file) { |i| defacer.compress(i) }

  row += [
    closure_gzipped_size,
    defacer_gzipped_size,
    percent_difference(closure_gzipped_size, defacer_gzipped_size, %w(smaller larger)),
    closure_elapsed,
    defacer_elapsed,
    percent_difference(closure_elapsed, defacer_elapsed, %w(faster slower)),
  ]

  # TODO show if we hit our goals or not

  rows << row
end

table = Terminal::Table.new(rows: rows)
puts table
