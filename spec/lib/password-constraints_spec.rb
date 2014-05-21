require 'spec_helper'

describe PasswordConstraints do
  it 'is a module' do
    expect(subject).to be_kind_of(Module)
  end

  context 'correct password' do
    let(:valid) { 'Bad-but-valid-99!' }
    it 'skips old password comparison when none provided' do
      expect(subject.validate(valid)).to eq([])
    end

    it 'does not accept old password as new' do
      expect(subject.validate(valid, valid)).to eq([
        'new password must differ from current'
      ])
    end
    
    it 'returns no error on valid password' do
      expect(subject.validate(valid, 'old-password')).to eq([])
    end
  end

  it 'mandates at least one digit' do
    expect(subject.validate('This-one-has-no-digit!')).to eq([
      "must contain at least one digit"
    ])
  end

  it 'mandates at least one uppercase character' do
    expect(subject.validate('nouppercase99!')).to eq([
      'must contain at least one uppercase character'
    ])
  end

  it 'mandates a special char' do
    expect(subject.validate('Nospecialchar99')).to eq([
      'must contain at least one special ASCII character'
    ])
  end

  it 'mandates a least 8 chars' do
    expect(subject.validate('Short9!')).to eq([
      'must have 8 or more character'
    ])
  end
end
