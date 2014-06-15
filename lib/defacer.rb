require 'defacer/version'

require 'rkelly'

module Defacer
  class WhitespaceRemovingVisitor < RKelly::Visitors::ECMAVisitor
    def initialize
      super
      @bound_var_names = {}
      @next_var_index = 0 # TODO do we need this? can we just use @bound_var_names.size?
      @function_depth = 0
    end

    def visit_SourceElementsNode(o)
      o.value.map { |x| "#{indent}#{x.accept(self)}" }.join
    end

    def visit_VarDeclNode(o)
      "#{bind_var_name(o)}#{o.value ? o.value.accept(self) : nil}"
    end

    def visit_FunctionBodyNode(o)
      # Track depth to determine if we are at global scope
      @function_depth += 1

      # Save the current binding
      saved_index = @next_var_index
      saved_bound_var_names = @bound_var_names.dup

      body = o.value.accept(self)

      # Restore the binding
      @next_var_index = saved_index
      @bound_var_names = saved_bound_var_names

      # Restore the depth
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

    def visit_OpEqualNode(o)
      "#{o.left.accept(self)}=#{o.value.accept(self)}"
    end

    # We've hit a new variable declaration, bind it to a shorter name
    def bind_var_name(o)
      if in_local_var_context
        @bound_var_names[o.name] = make_next_var
      else
        o.name
      end
    end

    def find_bound_name_for_var(o)
      @bound_var_names[o.value]
    end

    # Converts a zero-based index to a string of [a-z]. i.e.
    # 0 => a
    # 1 => b
    # 26 => aa
    # 27 => ab
    # 52 => ba
    # 53 => bb
    #
    # TODO test, simplify, and speed up this code
    def make_next_var
      v = ''
      x = @next_var_index

      # build up the string using the least-significant char first
      while x >= 0
        y = x % 26
        v = (y + 97).chr + v
        x -= (26 + y)
      end

      @next_var_index += 1

      v
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
