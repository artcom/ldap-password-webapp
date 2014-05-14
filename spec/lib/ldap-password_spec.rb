require 'spec_helper'

describe LdapPassword do
  it 'is a module' do
    expect(LdapPassword).to be_kind_of(Module)
  end

  it 'returns 4 bytes of salt' do
    expect(subject.salt_please).to be_kind_of(String)
    expect(subject.salt_please.size).to be(4)
  end

  it 'generates custom size salts' do
    expect(subject.salt_please(7).size).to be(7)
  end

  it 'loads the config' do 
    expect(subject.config).to be_kind_of(Hash)
  end

  it 'has a default port' do
    expect(subject.config['ldap_port']).to eq(389)
  end

  it 'defaults to simple auth' do
    expect(subject.config['ldap_auth_method']).to eq(:simple)
  end
end
