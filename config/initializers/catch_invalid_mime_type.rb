# frozen_string_literal: true

# Invalid Accept headers raise ActionDispatch::Http::MimeNegotiation::InvalidType
# during ActionController::Instrumentation#process_action (before rescue_from runs).
# Handle the exception here, inside DebugExceptions, to avoid multi-line backtraces.
class CatchInvalidMimeTypeMiddleware
  RESPONSE_BODY = "Not Acceptable: invalid or missing Accept header"

  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue ActionDispatch::Http::MimeNegotiation::InvalidType
    [406, { "Content-Type" => "text/plain" }, [RESPONSE_BODY]]
  end
end

Rails.application.config.middleware.insert_after ActionDispatch::DebugExceptions,
                                                  CatchInvalidMimeTypeMiddleware
