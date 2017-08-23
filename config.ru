$: << File.join(File.dirname(__FILE__), "lib")

tmpdir = File.join(File.dirname(__FILE__), 'tmp')
ENV['TMPDIR'] = tmpdir
Dir.mkdir(tmpdir) unless File.exist?(tmpdir)

require 'bundler'
require 'thumby'
#require 'newrelic_rpm'

if File.exists?(File.expand_path("../config/thumby.yaml", __FILE__))
  config = YAML.load_file(File.expand_path("../config/thumby.yaml", __FILE__))
else
  config = {:thumby_hostnames => %w( thumby thumby.heroku.com ), :preview_server => 'http://thumby', :options => {:nil => true}}
end

#NewRelic::Agent.after_fork(:force_reconnect => true)
run Thumby::SinatraApp.new(config[:thumby_hostnames], config[:preview_server], config[:options])
