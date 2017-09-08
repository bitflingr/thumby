require File.expand_path '../spec_helper.rb', __FILE__

describe 'Handling connection errors' do
  context 'receive connection refused when fetching from source' do
    it 'it should throw a handled exception error.' do
      get '/t/100x100/North/?url=http://localhost:9998/500x500.png'
      expect(last_response.status).to eq(502)
      expect(last_response.header['X-Message']).to match(/^Connection Refused!!!!  Exception: Failed to open TCP connection to(.*)\(Connection refused - connect\(2\) for (.*)\)/)
    end
  end

  context 'receive timeout error when fetching from source' do
    it 'it should throw a handled exception error.' do
      stubbed_request = stub_request(:any, 'http://webmo.ck/timeout.png').
        with(headers: {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
          to_timeout

      get '/t/100x100/North/?url=http://webmo.ck/timeout.png'
      expect(last_response.status).to eq(504)
      expect(last_response.header['X-Message']).to match(/^Gateway Timeout - (.*)$/)

      remove_request_stub(stubbed_request)
    end
  end

  context 'receive socket error when fetching from source' do
    it 'it should throw a handled exception error.' do
      stubbed_request = stub_request(:any, 'http://webmo.ck/socket.png').
        with(headers: {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).
        to_raise(SocketError)

      get '/t/100x100/North/?url=http://webmo.ck/socket.png'
      expect(last_response.status).to eq(502)
      expect(last_response.header['X-Message']).to match(/^Socket Error: (.*)$/)

      remove_request_stub(stubbed_request)
    end
  end
end
