require 'defacer/version'

require 'rkelly'

module Defacer
  class WhitespaceRemovingVisitor < RKelly::Visitors::ECMAVisitor
    def initialize
      super
      @bound_var_names = {}
      @next_var_ascii_code = 'a'[0].ord
      @function_depth = 0
    end

    def visit_SourceElementsNode(o)
      o.value.map { |x| "#{indent}#{x.accept(self)}" }.join
    end

    def visit_VarDeclNode(o)
      "#{bind_var_name(o)}#{o.value ? o.value.accept(self) : nil}"
    end

    def visit_FunctionBodyNode(o)
      @function_depth += 1
      saved_code = @next_var_ascii_code
      body = o.value.accept(self)
      @next_var_ascii_code = saved_code
      @function_depth -= 1
      "{#{body}}"
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

    def visit_ResolveNode(o)
      find_bound_name_for_var(o) || super(o)
    end

    # We've hit a new variable declaration, bind it to a shorter name
    def bind_var_name(o)
      if in_local_var_context
        bound = @next_var_ascii_code.chr
        @next_var_ascii_code += 1
        @bound_var_names[o.name] = bound
        bound
      else
        o.name
      end
    end

    def find_bound_name_for_var(o)
      @bound_var_names[o.value]
    end

    def in_local_var_context
      @function_depth > 0
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
