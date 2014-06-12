require "defacer/version"

require 'rkelly'

module Defacer
  class WhitespaceRemovingVisitor < RKelly::Visitors::ECMAVisitor
    def visit_SourceElementsNode(o)
      o.value.map { |x| "#{indent}#{x.accept(self)}" }.join
    end

    def visit_FunctionBodyNode(o)
      "{#{o.value.accept(self)}}"
    end
  end

  def self.compress(source)
    parser = RKelly::Parser.new
    ast = parser.parse(source)
    if ast # TODO test this case
      WhitespaceRemovingVisitor.new.accept(ast)
    else
      ''
    end
  end
end
