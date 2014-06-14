require 'spec_helper'
describe Defacer do

  let(:example_google_maps) { IO.read 'spec/fixtures/google_maps_example.js' }

  it 'should be able to handle some moderately complex js' do
    expect { Defacer.compress example_google_maps }.to_not raise_error(Exception)
  end

  let(:example_jquery) { IO.read 'spec/fixtures/jquery-2.1.1.js' }

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
    expect(Defacer.compress function).to eq("function double(x){return x*2;}")
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

  it 'should remove spaces from function call argument lists' do
    fn_call = "foo(a, 'b', 10);"
    minified = "foo(a,'b',10);"
    expect(Defacer.compress fn_call).to eq(minified)
  end

  it 'should remove spaces from function decl argument lists' do
    fn_decl = "function bar(x, y) {return x - y;}"
    minified = "function bar(x,y){return x-y;}"
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

  it 'should shorten var names in non-functional scope declarations'

  # TODO make sure it is outputting valid JS!
end
