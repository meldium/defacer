require 'defacer/namer'
require 'defacer/version'

require 'rkelly'

module Defacer
  class WhitespaceRemovingVisitor < RKelly::Visitors::ECMAVisitor
    def initialize
      super
      @bound_var_names = {}
      @function_depth = 0
    end

    def visit_SourceElementsNode(o)
      o.value.map { |x| "#{x.accept(self)}" }.join
    end

    def visit_VarStatementNode(o)
      "var #{o.value.map { |x| x.accept(self) }.join(',')};"
    end

    def visit_VarDeclNode(o)
      "#{bind_var_name(o.name)}#{o.value ? o.value.accept(self) : nil}"
    end

    def visit_FunctionBodyNode(o)
      "{#{o.value.accept(self)}}"
    end

    def visit_BlockNode(o)
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

    [
      [:Add, '+'],
      [:BitAnd, '&'],
      [:BitOr, '|'],
      [:BitXOr, '^'],
      [:Divide, '/'],
      [:Equal, '=='],
      [:Greater, '>'],
      [:GreaterOrEqual, '>='],
      [:LeftShift, '<<'],
      [:Less, '<'],
      [:LessOrEqual, '<='],
      [:LogicalAnd, '&&'],
      [:LogicalOr, '||'],
      [:Modulus, '%'],
      [:Multiply, '*'],
      [:NotEqual, '!='],
      [:NotStrictEqual, '!=='],
      [:OpAndEqual, '&='],
      [:OpDivideEqual, '/='],
      [:OpLShiftEqual, '<<='],
      [:OpMinusEqual, '-='],
      [:OpModEqual, '%='],
      [:OpMultiplyEqual, '*='],
      [:OpOrEqual, '|='],
      [:OpPlusEqual, '+='],
      [:OpRShiftEqual, '>>='],
      [:OpURShiftEqual, '>>>='],
      [:OpXOrEqual, '^='],
      [:RightShift, '>>'],
      [:StrictEqual, '==='],
      [:Subtract, '-'],
      [:UnsignedRightShift, '>>>'],
    ].each do |name,op|
      define_method(:"visit_#{name}Node") do |o|
        "#{o.left.accept(self)}#{op}#{o.value.accept(self)}"
      end
    end

    def visit_SwitchNode(o)
      "switch(#{o.left.accept(self)})#{o.value.accept(self)}"
    end

    def visit_CaseBlockNode(o)
      "{" + (o.value ? o.value.map { |x| x.accept(self) }.join('') : '') + "}"
    end

    def visit_CaseClauseNode(o)
      if o.left
        case_code = "case #{o.left.accept(self)}:"
      else
        case_code = "default:"
      end
      case_code += "#{o.value.accept(self)}"
      case_code
    end

    def visit_ResolveNode(o)
      find_bound_name_for_var(o) || super(o)
    end

    def visit_OpEqualNode(o)
      "#{o.left.accept(self)}=#{o.value.accept(self)}"
    end

    def visit_IfNode(o)
      statement = "if(#{o.conditions.accept(self)})#{o.value.accept(self)}"
      if else_statement = o.else
        if else_statement.kind_of? RKelly::Nodes::BlockNode
          statement += "else#{o.else.accept(self)}"
        else
          statement += "else #{o.else.accept(self)}"
        end
      end
      statement
    end

    def visit_ForNode(o)
      init    = o.init ? o.init.accept(self) : ';'
      init    << ';' unless init.end_with? ';' # make sure it has a ;
      test    = o.test ? o.test.accept(self) : ''
      counter = o.counter ? o.counter.accept(self) : ''
      "for(#{init}#{test};#{counter})#{o.value.accept(self)}"
    end

    # We've hit a new variable declaration, bind it to a shorter name
    def bind_var_name(o)
      if in_local_var_context
        @bound_var_names[o] = make_next_var
      else
        o
      end
    end

    def find_bound_name_for_var(o)
      @bound_var_names[o.value]
    end

    def make_next_var
      Defacer::Namer.name_var_at_index(@bound_var_names.size)
    end

    def make_var_at_index(x)
    end

    def in_local_var_context
      @function_depth > 0
    end

    def function_params_and_body(o)
      # Track depth to determine if we are at global scope
      @function_depth += 1

      # Save the current binding
      saved_bound_var_names = @bound_var_names.dup

      "(#{o.arguments.map { |x| bind_var_name(x.value) }.join(',')})" +
        "#{o.function_body.accept(self)}"

    ensure
      # Restore the binding
      @bound_var_names = saved_bound_var_names

      # Restore the depth
      @function_depth -= 1
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
