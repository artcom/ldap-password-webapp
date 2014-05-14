require 'spec_helper'

describe Ac::Ldap do
  it 'is a module' do
    expect(Ac::Ldap).to be_kind_of(Module)
  end

  it 'returns 4 bytes of salt' do
    expect(subject.salt_please).to be_kind_of(String)
    expect(subject.salt_please.size).to be(4)
  end

  it 'allows for longer salts' do
    expect(subject.salt_please(7).size).to be(7)
  end
end
