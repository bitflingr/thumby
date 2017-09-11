require File.expand_path '../spec_helper.rb', __FILE__

describe 'Base64 encoded urls' do
  context 'Fetching image from url that is base64 encoded.' do
    it 'returns 200' do
      get '/t/200x200/North/aHR0cDovL2xvY2FsaG9zdDo5OTk5LzUwMHg1MDAucG5n'
      expect(last_response).to be_ok
    end
  end

  context 'Handelining a bade base64 url should throw handled error' do
    it 'returns 400' do
      get '/t/200x200/North/aHR0cDovL2xvY2FsaG9zdDo5OTk5LzUwMHg1MDAucG5'
      expect(last_response.status).to eq(400)
      expect(last_response.header['X-Message']).to match(/^Invalid Base64 - (.*)/)
    end
  end
end
