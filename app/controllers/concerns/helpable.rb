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

    # content-types registered for that DOI
    def get_registered_content_types(id)
      doi = doi_from_url(id)
      url = "#{ENV['API_URL']}/dois/#{doi}"
      response = Maremma.get url
      Array.wrap(response.body.fetch("included", nil)).select { |m| m["type"] == "media" }.reduce({}) do|sum, media|
        content_type = media.dig("attributes", "mediaType")
        url = media.dig("attributes", "url")
        sum[content_type.strip] = url.strip if content_type.present? && url.present? 
        sum
      end.to_h
    end

    def available_content_types
      content_types = Mime::LOOKUP.map { |k, v| [k, v.to_sym] }.to_h
      content_types.except("text/html", "application/xhtml+xml", "text/plain", "application/json", "text/x-json", "application/jsonrequest")
    end
  end
end
