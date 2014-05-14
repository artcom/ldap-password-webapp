require 'spec_helper'

describe 'the web app' do
  it 'must at least have welcome page' do
    get '/'
    expect(last_response.status).to eq(200)
  end
end
