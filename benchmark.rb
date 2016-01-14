#!/usr/bin/env ruby

require 'closure-compiler'
require 'defacer'
require 'uglifier'
require 'terminal-table'
require 'zlib'

def percent_difference(baseline, measured, labels)
  value = (measured.to_f - baseline.to_f) / baseline.to_f
  label = (value < 0) ? labels.first : labels.last
  rounded = (value.abs * 100).to_i
  "#{rounded}% #{label}"
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
  input = File.read(js_file)
  basename = js_file.split('/').last

  row = []
  row << basename

  closure_start_time = Time.now.to_f
  closure_minified = closure.compile(input)
  closure_gzipped_size = Zlib::Deflate.deflate(closure_minified).size
  closure_elapsed = ((Time.now.to_f - closure_start_time) * 1000).to_i

  defacer_start_time = Time.now.to_f
  defacer_minified = defacer.compress(input)
  defacer_gzipped_size = Zlib::Deflate.deflate(defacer_minified).size
  defacer_elapsed = ((Time.now.to_f - defacer_start_time) * 1000).to_i

  row += [closure_gzipped_size,
          defacer_gzipped_size,
          percent_difference(closure_gzipped_size, defacer_gzipped_size, %w(smaller larger)),
          closure_elapsed,
          defacer_elapsed,
          percent_difference(closure_elapsed, defacer_elapsed, %w(faster slower)),
         ]

  rows << row

  # TODO write out scripts for later analysis
end

table = Terminal::Table.new(rows: rows)
puts table
