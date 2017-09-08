require File.expand_path '../spec_helper.rb', __FILE__

describe 'redirect handling' do
  context 'receive infinite redirect loop' do
    it 'it should throw a handled exception error.' do
      stubbed_request = stub_request(:any, 'http://webmo.ck/1_redirect.png')
                        .to_return(status: [302, 'Moved Temporarily'],
                                   headers: {'Location' => 'http://webmo.ck/1_redirect.png'})
                        .with(headers: {'Accept'=>'*/*', 'User-Agent'=>'Ruby'})


      get '/t/100x100/North/?url=http://webmo.ck/1_redirect.png'
      expect(last_response.status).to eq(504)
      expect(last_response.header['X-Message']).to eq('Detected redirect loop')
      remove_request_stub(stubbed_request)
    end
  end
end
