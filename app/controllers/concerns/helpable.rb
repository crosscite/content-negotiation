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

    def get_landing_page_info(id: nil)
      return nil unless id.present?

      cached_status = Rails.cache.read("status/#{id}")
      return cached_status if cached_status.present?

      response = Maremma.head(id, timeout: 5)
      if response.headers && response.headers["Content-Type"].present?
        content_type = response.headers["Content-Type"].split(";").first
      else
        content_type = nil
      end

      info = { "status" => response.status,
               "content-type" => content_type,
               "checked" => Time.zone.now.utc.iso8601 }

      Rails.cache.write("status/#{id}", info, expires_in: 1.week)
      info
    end

    # media_type is registered in MDS, should match content-type returned
    def get_media_url_info(id: nil, media_type: nil)
      return nil unless id.present? && media_type.present?

      cached_status = Rails.cache.read("status/#{media_type}/#{id}")
      return cached_status if cached_status.present?

      response = Maremma.head(id, timeout: 5)
      if response.headers && response.headers["Content-Type"].present?
        content_type = response.headers["Content-Type"].split(";").first
      else
        content_type = nil
      end

      info = { "status" => response.status,
               "content-type" => content_type,
               "checked" => Time.zone.now.utc.iso8601 }

      Rails.cache.write("status/#{media_type}/#{id}", info, expires_in: 1.week)
      info
    end

    # content-types registered for that DOI
    def get_registered_content_types(id)
      doi = doi_from_url(id)
      media_url = Rails.env.production? ? "https://app.datacite.org" : "https://app.test.datacite.org"
      media_url += "/media?doi-id=#{doi}"
      response = Maremma.get media_url
      response.body.fetch("data", []).reduce({}) do|sum, media|
        content_type = media.dig("attributes", "media-type")
        url = media.dig("attributes", "url")
        sum[content_type] = url
        sum
      end.to_h
    end

    def available_content_types
      content_types = Mime::LOOKUP.map { |k, v| [k, v.to_sym] }.to_h
      content_types.except("text/html", "application/xhtml+xml", "text/plain", "application/json", "text/x-json", "application/jsonrequest")
    end
  end
end
