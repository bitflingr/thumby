require File.expand_path '../spec_helper.rb', __FILE__

describe 'URL Encoding Scenarios' do
  context 'Fetching a normal image with all params' do
    it 'returns 200' do
      get '/t/200x200/North/?url=http://localhost:9999/500x500.png'
      expect(last_response).to be_ok
    end
  end

  context 'Fetching a image with abnormal chars' do
    it 'returns 200' do
      get '/t/200x200/North/?url=http%3A%2F%2Flocalhost:9999%2F500%20500.png'
      expect(last_response).to be_ok
    end
  end

  context 'Fetching image with %20' do
    it 'returns 200' do
      get '/t/200x200/North/?url=http://localhost:9999/500%20500.png'
      expect(last_response).to be_ok
    end
  end

  context 'Fetching image with %20 encoded' do
    it 'returns 200' do
      get '/t/200x200/North/?url=http%3A%2F%2Flocalhost:9999/500%2520500.png'
      expect(last_response).to be_ok
    end
  end

  context 'Fetching image with that has non-ASCII chars, because the internet is full of dodo heads' do
    it 'returns 200' do
      get '/t/200x200/North/?url=http%3A%2F%2Flocalhost%3A9999%2F15-Potential-New-Year%E2%80%99s-Resolutions-for-Crazy-Sports-Fans.jpg'
      expect(last_response).to be_ok
    end
  end

  context 'Fetching a html page should return a error' do
    it 'returns 500' do
      get '/t/200x200/North/?url=https://www.google.com'
      expect(last_response.status).to eq(500)
    end
  end

  context 'Fetching a image url that has {}' do
    it 'returns 200' do
      get '/t/200x200/North/?url=http%3A%2F%2Flocalhost%3A9999%2F500x%7B500%7D.png'
      expect(last_response).to be_ok
    end
  end

end