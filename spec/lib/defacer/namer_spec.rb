require 'spec_helper'

describe Defacer::Namer do
  it 'should start with a' do
    expect(Defacer::Namer.name_var_at_index(0)).to eq('a')
  end

  it 'should end at z' do
    expect(Defacer::Namer.name_var_at_index(25)).to eq('z')
  end

  it 'should continue to aa' do
    expect(Defacer::Namer.name_var_at_index(26)).to eq('aa')
  end

  it 'should go through az' do
    expect(Defacer::Namer.name_var_at_index(51)).to eq('az')
  end

  it 'should then use ba' do
    expect(Defacer::Namer.name_var_at_index(52)).to eq('ba')
  end

  it 'should cycle on to ca' do
    expect(Defacer::Namer.name_var_at_index(78)).to eq('ca')
  end

  it 'should take a while to get to three letter names', focus: true do
    expect(Defacer::Namer.name_var_at_index(27 * 26)).to eq('aaa')
  end
end
