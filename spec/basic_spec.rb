require File.expand_path '../spec_helper.rb', __FILE__

describe 'The Basic Endpoints' do
  context 'Hitting the splash page' do
    it 'returns 200' do
      get '/'
      expect(last_response.status).to eq(200)
    end
  end

  context 'can get to docs' do
    it 'says OK' do
      get '/docs'
      expect(last_response).to be_ok
    end
  end

  context 'pingdom checks in' do
    it 'says OK' do
      get '/pingdom'
      expect(last_response).to be_ok
      expect(last_response.body).to eq('OK')
    end
  end
end
