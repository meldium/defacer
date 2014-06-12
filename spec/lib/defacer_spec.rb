require 'spec_helper'
describe Defacer do
  it 'should echo back a simple expression' do
    expression = '1 + 1;'
    expect(Defacer.compile expression).to eq(expression)
  end

  it 'should remove newlines' do
    expect(Defacer.compile "1 + 1;\n2 + 2").to eq("1 + 1;2 + 2;")
  end

  it 'should remove all whitespace in functions' do
    function = "function double(x){\n  return x * 2;\n}\n"
    expect(Defacer.compile function).to eq("function double(x) {return x * 2;}")
  end

  let(:google_maps_example) { IO.read 'spec/fixtures/google_maps_example.js' }

  it 'should be able to handle some moderately complex js' do
    expect { Defacer.compile google_maps_example }.to_not raise_error(Exception)
  end
end
