require File.expand_path '../spec_helper.rb', __FILE__

describe 'URL Parameter Scenarios' do
  # context 'detect a thumby url' do
  #   it 'should detect a thumby url and fetch the original url instead' do
  #     get '/t/200x200/North/?url=http://localhost:9393/t/50x50/North/?url=http://localhost:9999/500x500.png'
  #     last_response.should be_ok
  #   end
  # end

  context 'Throw a 400 if url param is missing' do
    it 'throws 400 error' do
      expect do
        get '/t/200x200/North/'
        last_response.status.to eq(400)
        last_response.headers['X-Message'].to eq('Bad Request - url pramater required.')
      end
    end
  end

  context 'Throw a 400 if url param has bad url scheme' do
    it 'throws 400 error' do
      expect do
        get '/t/200x200/North/?url=http:/cdn.americansongwriter.com/wp-content/uploads/2010/02/frank-1.jpg'
        last_response.status.to eq(400)
        last_response.header['X-Message'].to eq('Bad Request - Bad url parameter, https?://.* not found')
      end
    end
  end

  context 'Throw a 404 if url is 404' do
    it 'throws 404 error' do
      expect do
        get "/t/200x200/North/?url=#{server}/404.html"
        last_response.status.to eq(404)
      end
    end
  end

  context 'fetch image that has "http:" in the uri' do
    it 'should return 200' do
      expect do
        get "/t/72x72/North/?url=#{server}/500x500.png?foo=bar&url=http://google.com"
        last_response.status.to eq(200)
      end
    end
  end

end
