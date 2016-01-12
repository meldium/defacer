require 'execjs'
require 'spec_helper'

describe Defacer do

  let(:example_google_maps) { IO.read 'spec/fixtures/google_maps_example.js' }

  it 'should be able to handle some moderately complex js' do
    expect { Defacer.compress example_google_maps }.to_not raise_error(Exception)
  end

  let(:example_jquery) { IO.read 'spec/fixtures/benchmarks/jquery-2.1.1.js' }

  it 'should be able to handle some very complex js' do
    expect { Defacer.compress example_jquery }.to_not raise_error(Exception)
  end

  it 'should echo back an unminifiable expression' do
    expression = '1+1;'
    expect(Defacer.compress expression).to eq(expression)
  end

  it 'should remove newlines' do
    expect(Defacer.compress "1 + 1;\n2 + 2").to eq("1+1;2+2;")
  end

  it 'should remove all whitespace in functions' do
    function = "function double(x){\n  return x * 2;\n}\n"
    expect(Defacer.compress function).to eq("function double(a){return a*2;}")
  end

  it 'should remove whitespace inside object literals' do
    literal = "var mapOptions = {\n  zoom: 3,\n  center: chicago\n};"
    minified = "var mapOptions={zoom:3,center:chicago};"
    expect(Defacer.compress literal).to eq(minified)
  end

  it 'should remove spaces in var assignment statements' do
    assignment = "var meaningOfLife = 42;"
    minified = "var meaningOfLife=42;"
    expect(Defacer.compress assignment).to eq(minified)
  end

  it 'should remove spaces in reassignments' do
    reassignment = "meaningOfLife = 42;"
    minified = "meaningOfLife=42;"
    expect(Defacer.compress reassignment).to eq(minified)
  end

  it 'should remove spaces from function call argument lists' do
    fn_call = "foo(a, 'b', 10);"
    minified = "foo(a,'b',10);"
    expect(Defacer.compress fn_call).to eq(minified)
  end

  it 'should remove spaces from function decl argument lists' do
    fn_decl = "function bar(x, y) {return x - y;}"
    minified = "function bar(a,b){return a-b;}"
    expect(Defacer.compress fn_decl).to eq(minified)
  end

  it 'should remove spaces between binary operators' do
    expect(Defacer.compress 'a + b;').to eq('a+b;')
    expect(Defacer.compress 'a - b;').to eq('a-b;')
    expect(Defacer.compress 'a * b;').to eq('a*b;')
    expect(Defacer.compress 'a / b;').to eq('a/b;')
  end

  it 'should remove whitespace in array literals' do
    array = "var arr = ['1',  2, a,\n   b,'c'];"
    minified = "var arr=['1',2,a,b,'c'];"
    expect(Defacer.compress array).to eq(minified)
  end

  it 'should remove whitespace in variable lists' do
    assignments = "var a = 42, b = 43;"
    minified = "var a=42,b=43;"
    expect(Defacer.compress assignments).to eq(minified)
  end

  it 'should remove whitespace in if...else statements' do
    if_else = 'if (2 > 1) { return x; } else { return 99; }'
    minified = 'if(2>1){return x;}else{return 99;}'
    expect(Defacer.compress if_else).to eq(minified)
  end

  it 'should remove whitespace in if..else if..else statements' do
    statement = 'if (2 > 1) { return x; } else if (3 > 2) { return 2; } else { return 99; }'
    minified = 'if(2>1){return x;}else if(3>2){return 2;}else{return 99;}'
    expect(Defacer.compress statement).to eq(minified)
  end

  it 'should correctly remove whitespace in non-block if..else statements' do
    statement = 'if (2 > 1) return x; else return y;'
    minified = 'if(2>1)return x;else return y;'
    expect(Defacer.compress statement).to eq(minified)
  end

  it 'should remove whitespace in for statements' do
    for_statement = 'for (var i = 0; i < 12; i += 1) { x = x + i; }'
    minified = 'for(var i=0;i<12;i+=1){x=x+i;}'
    expect(Defacer.compress for_statement).to eq(minified)
  end

  it 'should rename local variables' do
    js = 'function fooBar(){ var localA = 2; return localA + 2; }'
    minified = 'function fooBar(){var a=2;return a+2;}'
    expect(Defacer.compress js).to eq(minified)
  end

  it 'should rename local variables, but not global variables' do
    js = 'var globalA = 1; function fooBar(){ var localA = 2; var localB = function(){ var localC = 3; return globalA + localA + localC + 5;}(); return localA + localB; }';
    minified = 'var globalA=1;function fooBar(){var a=2;var b=function(){var c=3;return globalA+a+c+5;}();return a+b;}';
    expect(Defacer.compress js).to eq(minified)
  end

  it 'should recycle bound var names in sibling functions' do
    js = 'function foo(){ var localA = 2; return localA + 2; };function bar(){ var localB = 4; return localB + 4; }'
    minified = 'function foo(){var a=2;return a+2;};function bar(){var a=4;return a+4;}'
    expect(Defacer.compress js).to eq(minified)
  end

  it 'does not mix variable name bindings across sibling blocks' do
    js = 'function alpha(){ var foo = 1, bar = 2, baz = 3, quux = 4; return foo*bar*baz*quux; };function beta(){ var baz = 4, quux = 9; return quux - baz; }'
    minified = 'function alpha(){var a=1,b=2,c=3,d=4;return a*b*c*d;};function beta(){var a=4,b=9;return b-a;}'
    expect(Defacer.compress js).to eq(minified)
  end

  let(:hella_variable_names) { IO.read 'spec/fixtures/hella_variable_names.js' }

  it 'should be able to shorten more than 26 variable names' do
    compressed = Defacer.compress(hella_variable_names)
    # Look for two-char names like aa, ab
    expect(compressed).to match(/aa/)
    expect(compressed).to match(/ab/)
  end

  it 'will not shorten local names even if var keyword is omitted' do
    js = 'var x = function(){veryLongVarName = 2; var otherLongVarName = 5; return veryLongVarName + otherLongVarName;}()'
    minified = 'var x=function(){veryLongVarName=2;var a=5;return veryLongVarName+a;}();'
    expect(Defacer.compress js).to eq(minified)
  end

  it 'should correctly shorten shadowed names' do
    js = "var result = function(){var foo = 2, bar = 3; return function(){var bar = 9; return bar + 1;}() + foo + bar;}();"
    minified = "var result=function(){var a=2,b=3;return function(){var c=9;return c+1;}()+a+b;}();"
    expect(Defacer.compress js).to eq(minified)

    # Actually run the JS to make sure the transformation is safe
    expect(ExecJS.compile(js).eval('result')).to eq(15) # precondition
    expect(ExecJS.compile(minified).eval('result')).to eq(15) # our version
  end

  it 'should correctly shorted shadowed names in function parameters' do
    js = "var result = function(){var foo = 2, bar = 3; return function(bar){return bar + 1;}(foo) + foo + bar;}();"
    minified = "var result=function(){var a=2,b=3;return function(c){return c+1;}(a)+a+b;}();"
    expect(Defacer.compress js).to eq(minified)

    # Actually run the JS to make sure the transformation is safe
    expect(ExecJS.compile(js).eval('result')).to eq(8) # precondition
    expect(ExecJS.compile(minified).eval('result')).to eq(8) # our version
  end

  let(:example_underscore) { IO.read 'spec/fixtures/benchmarks/underscore.js' }

  it 'should correctly minify underscore', focus: true do
    minified = Defacer.compress(example_underscore)
    compiled = ExecJS.compile(minified)
    result = compiled.eval('_.max([1, 42, 3, 9, 0])')
    expect(result).to eq(42)
  end

  # TODO improve angular, worst minification of examples
  # TODO rename functions declared like function fooBar(){} if they are not at global scope


  # TODO still a lot of extra whitespace

  it 'should remove unused code' # yikes!
end
