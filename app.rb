# # load ENV variables from .env file if it exists
env_file =  File.expand_path("../.env", __FILE__)
if File.exist?(env_file)
  require 'dotenv'
  Dotenv.load! env_file
end

# load ENV variables from container environment if json file exists
# see https://github.com/phusion/baseimage-docker#envvar_dumps
env_json_file = "/etc/container_environment.json"
if File.exist?(env_json_file)
  env_vars = JSON.parse(File.read(env_json_file))
  env_vars.each { |k, v| ENV[k] = v }
end

require 'active_support/all'

# required ENV variables, can be set in .env file
ENV['APPLICATION'] ||= "content-negotiation"
ENV['SITE_TITLE'] ||= "DataCite Content Resolver"
ENV['LOG_LEVEL'] ||= "info"
ENV['API_URL'] ||= "https://api.datacite.org"
ENV['SEARCH_URL'] ||= "https://search.datacite.org"

env_vars = %w(SITE_TITLE LOG_LEVEL API_URL)
env_vars.each { |env| fail ArgumentError,  "ENV[#{env}] is not set" unless ENV[env].present? }

require 'sinatra'
require 'sinatra/json'
require 'sinatra/contrib'
require 'sinatra/config_file'
require 'cgi'
require 'maremma'
require 'bolognese'
require 'open-uri'
require 'uri'
require 'better_errors'

Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each { |f| require f }

LOG_LEVELS = {
  "debug" => ::Logger::DEBUG,
  "info" => ::Logger::INFO,
  "warn" => ::Logger::WARN,
}

configure do
  set :app_file, __FILE__

  set :default_encoding, "UTF-8"

  # Work around rack protection referrer bug
  set :protection, except: :json_csrf

  # Set log level
  set :logging, LOG_LEVELS[ENV['LOG_LEVEL']]

  # include bolognese utility methods
  include Bolognese::Utils
  include Bolognese::DoiUtils

  # optionally use Bugsnag for error tracking
  if ENV['BUGSNAG_KEY']
    require 'bugsnag'
    Bugsnag.configure do |config|
      config.api_key = ENV['BUGSNAG_KEY']
      config.project_root = settings.root
      config.app_version = App::VERSION
      config.release_stage = ENV['RACK_ENV']
      config.notify_release_stages = %w(production stage development)
    end

    use Bugsnag::Rack
    enable :raise_errors
  end
end

configure :development do
  use BetterErrors::Middleware
  BetterErrors::Middleware.allow_ip! ENV['TRUSTED_IP']
  BetterErrors.application_root = File.expand_path('..', __FILE__)

  enable :raise_errors, :dump_errors
  # disable :show_exceptions
end

after do
  response.headers['Access-Control-Allow-Origin'] = '*'
end

get '/heartbeat' do
  content_type 'text/html'

  'OK'
end

get '/' do
  content_type 'text/html'

  "Content Negotiation"
end

# return content in one of the formats supported by bolognese gem
get %r{/content/([^/]+/[^/]+)/(.+)} do
  # id can be DOI or DOI expressed as URL
  id = Bolognese::Utils.normalize_id(params[:captures].last)
  halt 404, "#{params[:captures].last} not found" unless id.present?

  # from is DOI registration agency name
  from = Bolognese::Utils.find_from_format(id: id)

  content_type = params[:captures].first
  to = available_content_types[content_type]
  halt 404, "content for #{content_type} not supported" unless to.present?

  logger.info "#{id} as #{content_type}"

  content_type content_type

  # generate metadata
  generate(id: id, from: from, to: to)
end

# legacy support for link-based text/html
# text/html in accept header is handled by handle proxy
get %r{/text/html/(.+)} do
  # id can be DOI or DOI expressed as URL
  id = Bolognese::Utils.normalize_id(params[:captures].first)
  halt 404, "#{params[:captures].first} not found" unless id.present?

  url = ENV['SEARCH_URL'] + "works/" + doi_from_url(id)
  logger.info "#{id} as text/html"

  content_type "text/html"

  redirect url, 303
end

# link-based content type
get %r{/([^/]+/[^/]+)/(.+)} do
  # id can be DOI or DOI expressed as URL
  id = Bolognese::Utils.normalize_id(params[:captures].last)
  halt 404, "#{params[:captures].last} not found" unless id.present?

  accept_header = [params[:captures].first]
  url = redirect_by_content_type(id: id, accept_header: accept_header)

  logger.info "#{id} as #{accept_header.first}"

  content_type accept_header.first

  headers['Link'] = "<#{id}> ; rel=\"identifier\", " +
                  "<#{id}> ; rel=\"describedby\" ; type=\"application/vnd.datacite.datacite+xml\", " +
                  "<#{id}> ; rel=\"describedby\" ; type=\"application/vnd.citationstyles.csl+json\", " +
                  "<#{id}> ; rel=\"describedby\" ; type=\"application/x-bibtex\""

  redirect url, 303
end

# content type via accept header
get %r{/(.+)} do
  # id can be DOI or DOI expressed as URL
  id = Bolognese::Utils.normalize_id(params[:captures].first)
  halt 404, "#{params[:captures].first} not found" unless id.present?

  accept_header = request.accept.map { |a| a.to_s }
  url = redirect_by_content_type(id: id, accept_header: accept_header)

  logger.info "#{id} as #{accept_header.first}"

  content_type accept_header.first

  headers['Link'] = "<#{id}> ; rel=\"identifier\", " +
                  "<#{id}> ; rel=\"describedby\" ; type=\"application/vnd.datacite.datacite+xml\", " +
                  "<#{id}> ; rel=\"describedby\" ; type=\"application/vnd.citationstyles.csl+json\", " +
                  "<#{id}> ; rel=\"describedby\" ; type=\"application/x-bibtex\""

  redirect url, 303
end
