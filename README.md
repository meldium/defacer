# Defacer

A pure-Ruby javascript minifier. Currently alpha quality - we do not
recommend you use this for production code.

# Design goals

* Be faster than any of the minifiers commonly used in Ruby projects (Uglifier, Closure Compiler, YUI Compressor).
* Create code that, when gzipped, is no more than 5% larger than the code created by other minifiers.
* Be written in pure Ruby. Why?
    * It makes it easier for Ruby devs to hack on Defacer and improve it
    * It reduces deployment complexity - no need to have a JVM or a Javascript runtime
    * It's cross-platform for free

# Performance

The `benchmark.rb` script included with the gem compares Defacer to
Uglifier and Closure. It measures the size of the minified JS, the
size of the minified JS after gzipping, and the speed of the
minification. As of June 2014, Defacer is faster than all other
minifiers (though not much faster on large input files), but creates
code that is 5-25% larger than other minifiers.

## Installation

Defacer is distributed as a Rubygem. Add this line to your application's Gemfile:

    gem 'defacer'

And then execute:

    $ bundle

## Using with Rails

Instructions coming soon

## Contributing

Pull requests are welcome! Pull requests containing tests are even better!!
