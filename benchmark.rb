#!/usr/bin/env ruby

require 'defacer'
require 'uglifier'
require 'terminal-table'
require 'zlib'

commands = {
  defacer: ->(js) { Defacer.compress(js) },
  uglifier: ->(js) { Uglifier.new.compress(js) },
}

header = ['script', 'size (b)']
commands.keys.each do |key|
  command_name = key.to_s
  header += [command_name + ' (ms)', command_name + ' (min)', command_name + ' (gz)']
end

rows = [header, :separator]

Dir['spec/fixtures/*.js'].each do |js_file|
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

table = Terminal::Table.new(rows: rows)
1.upto(rows.first.size) { |i| table.align_column i, :right }
puts table
