#!/usr/bin/env ruby

require 'closure-compiler'
require 'defacer'
require 'uglifier'
require 'terminal-table'
require 'zlib'

defacer = Defacer
closure = Closure::Compiler.new
uglifier = Uglifier.new

commands = {
  defacer: ->(js) { defacer.compress(js) },
  uglifier: ->(js) { uglifier.compress(js) },
  closure: ->(js) { closure.compile(js) },
}

header = ['script', 'original (b)'] # TODO original gz?
commands.keys.each do |key|
  command_name = key.to_s
  header += [command_name + ' (ms)', command_name + ' (min)', command_name + ' (gz)']
end

rows = [header]

Dir['spec/fixtures/benchmarks/*.js'].each do |js_file|
  input = File.read(js_file)

  row = [js_file.split('/').last, input.size]

  commands.each do |command_name, command|
    start_time = Time.now.to_f
    minified = command.call(input)
    elapsed = Time.now.to_f - start_time
    gzipped = Zlib::Deflate.deflate(minified)
    row += [(elapsed * 1000).to_i, minified.size, gzipped.size]
  end

  rows << row
end

# Tunrs out that it looks better if you invert the table
inverted = []
0.upto(rows.first.length - 1).each do |col|
  inverted << rows.map { |r| r[col] }
end

# Add some separators
1.upto(commands.size).each { |i| inverted.insert((-3 * i) - i, :separator) }
inverted.insert(1, :separator)

table = Terminal::Table.new(rows: inverted)
1.upto(inverted.first.size) { |i| table.align_column i, :right }
puts table
