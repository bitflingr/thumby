require 'rubygems'
require 'sinatra'
require 'sinatra/static_assets'
require 'sinatra/simple-navigation'
require 'kramdown'
require 'dragonfly'
require 'yaml'
require 'net/http'
require 'base64'
require 'openssl'
require 'addressable/uri'
require 'erb'
# require 'aws-sdk'

class Thumby # :nodoc:
  require 'thumby/monkey_patches'
  require 'thumby/sinatra_app'
  require 'thumby/helpers'

  def initialize() end
end
