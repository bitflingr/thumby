#$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
ENV['RACK_ENV'] = 'test'
require 'webmock/rspec'
require 'simplecov'
require 'simplecov-rcov'
require 'codecov'
require 'rack/test'
require 'rspec/core'

WebMock.disable_net_connect!(allow: [
  'localhost',
  'www.google.com',
  'c402277.ssl.cf1.rackcdn.com'])

module RSpecMixin # :nodoc:
  include Rack::Test::Methods
  def app
    eval 'Rack::Builder.new {( ' + File.read(File.dirname(__FILE__) +
          '/../config.ru') + "\n )}"
  end
end

# For RSpec 2.x
RSpec.configure { |c| c.include RSpecMixin }

# Start up local static server
require 'thumby/test/static_server'

root_dir = File.expand_path '../../public/test', __FILE__
port = 9999
Thumby::Test::StaticServer.run!(root_dir: root_dir, port: port)

module SimpleCov
  module Formatter
    class MergedFormatter # :nodoc:
      def format(result)
        SimpleCov::Formatter::HTMLFormatter.new.format(result)
        SimpleCov::Formatter::Codecov.new.format(result)
      end
    end
  end
end

SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter

SimpleCov.start do
  add_filter '/vendor/'
  add_filter '/spec/'
  add_filter '/lib/thumby/test/static_server.rb'
end

require 'thumby' # File.expand_path '../../my-app.rb', __FILE__
