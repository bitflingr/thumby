require File.expand_path '../spec_helper.rb', __FILE__

describe 'HTTPS and encrypted url Scenarios' do
  # context 'decrypt url' do
  #   it 'decode and decrypt string and pass it forward to best matched url' do
  #     url = '/t/e/jCU2drN_yFvi8jWEeaZcFH27aHcuYLwoQHIIdM9GPvsfzyqVLvUuAHTwOl'\
  #           'tdLUoXtITTDLVFxcevgpUGFPCGtrqTIGk2l88X8uVth91YsGQhdwj7EVEVvKohC'\
  #           'NLeAiQAMt6giyKP7r1a8aiaVX1_JdwqGEVj2MTT8GJUgNgbjLJVBEEAHMFQ-FYH'\
  #           '0eK7WdX1?salt=acee6223aff94e63'
  #     get url
  #     last_response.status.should eq(200)
  #   end
  # end
  #
  # context 'decrypt Thumby url' do
  #   it 'expect 200 for decrypting a thumby url, through is_thumby_url?' do
  #     url = '/t/e/6U246WGalIKK7oedk1WnghNjBxY8KHnQcEFzxIW30bY3ioGduIzqvlovxi'\
  #           'dBQDcfbzzhtGrBdAdATBMQAUzhEHgEkaBk5PShTZpc46M4VjdDjPLnGZbez7eTi'\
  #           'vPF0MIvzj2SSzfZPJRfHLXoGneOKbPo7B6kwbMAT1VUY9jwqykedb5jPyXVP4QY'\
  #           'zbK8a01_tk9emUYjcLT6Bv0SuDmpQvjPttH2DB0kXFWuzRiRUChizqht-ZLWWOa'\
  #           'e3LmHvu1A'
  #     get url
  #     last_response.status.should eq(200)
  #   end
  # end

  context 'fetch image that is https' do
    it 'should be able to process images hosted in https' do
      expect do
        get '/t/100x100/North/?url=https://spthumbnails.5min.com/10363530/518176453_3v1_570_411.jpg'
        last_response.status.to eq(200)
      end
    end
  end
end
