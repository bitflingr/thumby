require File.expand_path '../spec_helper.rb', __FILE__

describe 'Handling connection errors' do
  context 'receive connection refused when fetching from source' do
    it 'it should throw a handled exception error.' do
      get '/t/100x100/North/?url=http://localhost:9998/500x500.png'
      expect(last_response.status).to eq(502)
      expect(last_response.header['X-Message']).to match(/^Connection Refused!!!!  Exception: Failed to open TCP connection to(.*)\(Connection refused - connect\(2\) for (.*)\)/)
    end
  end

  # context 'receive timeout error when fetching from source' do
  #   it 'it should throw a handled exception error.' do
  #     get '/t/100x100/North/?url=http://localhost:9999/500x500.png'
  #     raise_error(Timeout::Error)
  #     expect(last_response.status).to eq(502)
  #     # Net::HTTP.should_receive(:request_get).and_raise(Timeout::Error)
  #     expect(last_response.header['X-Message']).to match(/^Connection Refused!!!!  Exception: Failed to open TCP connection to(.*)\(Connection refused - connect\(2\) for (.*)\)/)
  #   end
  # end
end
