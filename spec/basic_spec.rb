# ENV['RACK_ENV'] = 'test'
require File.expand_path '../spec_helper.rb', __FILE__

describe 'The Basic Endpoints' do
  context 'Hitting the splash page' do
    it 'returns 200' do
      expect do
        get '/'
        last_response.to be_ok
      end
    end
  end

  context 'can get to docs' do
    it 'says OK' do
      expect do
        get '/docs'
        last_response.to be_ok
      end
    end
  end

  context 'pingdom checks in' do
    it 'says OK' do
      expect do
        get '/pingdom'
        last_response.to be_ok
        last_response.body.to eq('OK')
      end
    end
  end
end
