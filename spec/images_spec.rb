require File.expand_path '../spec_helper.rb', __FILE__

describe 'Tests different image formats and sizes' do
  context 'Fetching a .gif image' do
    it 'returns 200' do
      get '/t/200x200/North/?url=http://localhost:9999/archer.gif'
      expect(last_response).to be_ok
    end
  end

  context 'Fetching a image that is 0 bytes' do
    it 'returns 500' do
      get '/t/200x200/North/?url=http://localhost:9999/0.jpg'
      expect(last_response.status).to eq(500)
      # expect(last_response.header['X-Message']).to eq('image is 0 bytes!')
    end
  end

  context 'Fetching a image that is actually html' do
    it 'returns 500' do
      get '/t/200x200/North/?url=http://localhost:9999/index.html'
      expect(last_response.status).to eq(500)
      #expect(last_response.header['X-Message']).to eq('Detected url is an html and not a jpeg or png extension')
    end
  end

  context 'Fetching a image with blur padding' do
    it 'returns 200' do
      get '/b/200x50/North/?url=http://localhost:9999/500x500.png'
      expect(last_response.status).to eq(200)
    end
  end
end

