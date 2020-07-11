module Helpable
  extend ActiveSupport::Concern

  require "bolognese"
  require "maremma"

  included do
    include Bolognese::DoiUtils
    include Bolognese::Utils

    def get_handle_url(id: nil)
      response = Maremma.head(id, limit: 0)
      response.headers["location"]
    end

    def available_content_types
      content_types = Mime::LOOKUP.map { |k, v| [k, v.to_sym] }.to_h
      content_types.except("text/html", "application/xhtml+xml", "text/plain", "application/json", "text/x-json", "application/jsonrequest")
    end
  end
end
