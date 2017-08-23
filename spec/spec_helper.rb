$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
ENV['RACK_ENV'] = 'test'
require 'simplecov'
require 'simplecov-rcov'

module SimpleCov
  module Formatter
    class MergedFormatter # :nodoc:
      def format(result)
        SimpleCov::Formatter::HTMLFormatter.new.format(result)
        SimpleCov::Formatter::RcovFormatter.new.format(result)
      end
    end
  end
end

SimpleCov.formatter = SimpleCov::Formatter::MergedFormatter

SimpleCov.start do
  add_filter '/vendor/'
end

require 'rack/test'

require 'thumby' # File.expand_path '../../my-app.rb', __FILE__

module RSpecMixin # :nodoc:
  include Rack::Test::Methods
  def app
    eval 'Rack::Builder.new {( ' + File.read(File.dirname(__FILE__) +
          '/../config.ru') + "\n )}"
  end
end

# For RSpec 2.x
RSpec.configure { |c| c.include RSpecMixin }

# If you use RSpec 1.x you should use this instead:
# Spec::Runner.configure { |c| c.include RSpecMixin }

# Start up local static server
require 'thumby/test/static_server'

root_dir = File.expand_path '../../public/test', __FILE__
port = 9999
Thumby::Test::StaticServer.run!(root_dir: root_dir, port: port)
