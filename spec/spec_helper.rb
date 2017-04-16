Encoding.default_external = Encoding::UTF_8

ENV['RACK_ENV'] = 'test'

# set up Code Climate
require 'simplecov'
SimpleCov.start

require 'sinatra'
require 'rspec'
require 'rack/test'
require 'webmock/rspec'
require 'vcr'

require File.join(File.dirname(__FILE__), '..', 'app.rb')

# require files in lib folder
Dir[File.join(File.dirname(__FILE__), '../lib/**/*.rb')].each { |f| require f }

# setup test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false
set :dump_errors, false
set :show_exceptions, false

def app
  Sinatra::Application
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.order = :random
end

WebMock.disable_net_connect!(
  allow: ['codeclimate.com:443', ENV['PRIVATE_IP'], ENV['HOSTNAME']],
  allow_localhost: true
)

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.ignore_localhost = true
  c.ignore_hosts 'codeclimate.com'
  c.filter_sensitive_data('<ORCID_UPDATE_KEY>') { ENV['ORCID_UPDATE_KEY'] }
  c.filter_sensitive_data('<ORCID_UPDATE_TOKEN>') { ENV['ORCID_UPDATE_TOKEN'] }
  c.allow_http_connections_when_no_cassette = false
  c.configure_rspec_metadata!
end

def capture_stdout(&block)
  stdout, string = $stdout, StringIO.new
  $stdout = string

  yield

  string.tap(&:rewind).read
ensure
  $stdout = stdout
end
