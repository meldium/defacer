require 'defacer/version'

require 'rkelly'

module Defacer
  class WhitespaceRemovingVisitor < RKelly::Visitors::ECMAVisitor
    def visit_SourceElementsNode(o)
      o.value.map { |x| "#{indent}#{x.accept(self)}" }.join
    end

    def visit_FunctionBodyNode(o)
      "{#{o.value.accept(self)}}"
    end

    def visit_ObjectLiteralNode(o)
      '{' + o.value.map { |x| x.accept(self) }.join(',') + '}'
    end

    def visit_ArrayNode(o)
      "[#{o.value.map { |x| x ? x.accept(self) : '' }.join(',')}]"
    end

    def visit_PropertyNode(o)
      "#{o.name}:#{o.value.accept(self)}"
    end

    def visit_AssignExprNode(o)
      "=#{o.value.accept(self)}"
    end

    def visit_ArgumentsNode(o)
      o.value.map { |x| x.accept(self) }.join(',')
    end

    def visit_AddNode(o)
      "#{o.left.accept(self)}+#{o.value.accept(self)}"
    end

    def visit_SubtractNode(o)
      "#{o.left.accept(self)}-#{o.value.accept(self)}"
    end

    def visit_MultiplyNode(o)
      "#{o.left.accept(self)}*#{o.value.accept(self)}"
    end

    def visit_DivideNode(o)
      "#{o.left.accept(self)}/#{o.value.accept(self)}"
    end

    def function_params_and_body(o)
      "(#{o.arguments.map { |x| x.accept(self) }.join(',')})" +
        "#{o.function_body.accept(self)}"
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
