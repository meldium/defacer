#!/usr/bin/env ruby

require 'closure-compiler'
require 'defacer'
require 'uglifier'
require 'terminal-table'
require 'zlib'

defacer = Defacer
closure = Closure::Compiler.new

rows = [[
          'script',
          'size: unminified + gz',
          'size: closure + gz',
          'size: defacer + gz',
          'speed: closure + gz',
          'speed: defacer + gz',
        ]]

rows << :separator

callables = [
  ->(js) { defacer.compress(js) },
  ->(js) { closure.compile(js) },
]

Dir['spec/fixtures/benchmarks/*.js'].each do |js_file|
  input = File.read(js_file)
  basename = js_file.split('/').last

  row = []
  row << basename
  row << Zlib::Deflate.deflate(input).size

  closure_start_time = Time.now.to_f
  closure_minified = closure.compile(input)
  closure_gzipped = Zlib::Deflate.deflate(closure_minified)
  closure_elapsed = ((Time.now.to_f - closure_start_time) * 1000).to_i

  defacer_start_time = Time.now.to_f
  defacer_minified = defacer.compress(input)
  defacer_gzipped = Zlib::Deflate.deflate(defacer_minified)
  defacer_elapsed = ((Time.now.to_f - defacer_start_time) * 1000).to_i

  row += [closure_gzipped.size, defacer_gzipped.size, closure_elapsed, defacer_elapsed]

  rows << row
end

table = Terminal::Table.new(rows: rows)
puts table
