Sentry.init do |config|
  config.dsn = ENV["SENTRY_DSN"]
  config.release = "content-negotiation:" + ContentNegotiation::Application::VERSION
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.traces_sample_rate = 0.5
  config.send_default_pii = true
end
