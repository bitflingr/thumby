require File.expand_path '../spec_helper.rb', __FILE__

describe 'The Basic Endpoints' do
  #context 'Hitting the splash page' do
    #it 'returns 200' do
      #get '/'
      #expect(last_response.status).to eq(200)
    #end
  #end

  #context 'can get to docs' do
    #it 'says OK' do
      #get '/docs'
      #expect(last_response).to be_ok
    #end
  #end

  context 'pingdom checks in' do
    it 'says OK' do
      get '/pingdom'
      expect(last_response).to be_ok
      expect(last_response.body).to eq('OK')
    end
  end

  context 'fetch image that is https' do
    it 'should be able to process images hosted in https' do
      get '/t/100x100/North/?url=https://c402277.ssl.cf1.rackcdn.com/photos/11552/images/hero_full/rsz_namibia_will_burrard_lucas_wwf_us_1.jpg?1462219623'
      expect(last_response.status).to eq(200)
    end
  end

  context 'Fetching a normal image with all params' do
    it 'returns 200' do
      get '/t/200x200/North/?url=http://localhost:9999/500x500.png'
      expect(last_response).to be_ok
    end
  end
end
