module Sinatra
  module Helpers
    def normalize_id(id)
      Bolognese::Utils.normalize_id(id)
    end

    def doi_from_url(id)
      Bolognese::DoiUtils.doi_from_url(id)
    end

    def validate_doi(id)
      Bolognese::DoiUtils.validate_doi(id)
    end

    def generate(id: nil, from: nil, to: nil)
      Bolognese::Utils.generate(id: id, from: from, to: to)
    end

    # determine content-type for the response, in that order:
    # 1. content-type registered for DOI
    # 2. content-type available in content negotiation
    # 3. formatted citation via DOI formatter service
    # 4. no content-type found, pass through to URL registered in handle system
    # then redirect based on content_type
    def redirect_by_content_type(id: nil, accept_header: nil)
      should_redirect_registered(id: id, accept_header: accept_header) ||
      should_redirect_available(id: id, accept_header: accept_header) ||
      should_redirect_citation(id: nil, accept_header: nil) ||
      should_pass_thru(id: id)
    end

    def should_redirect_registered(id: nil, accept_header: nil)
      registered_content_types = get_registered_content_types(id)

      content_type = (accept_header & registered_content_types.keys).first
      registered_content_types[content_type]
    end

    def should_redirect_citation(id: nil, accept_header: nil)
      content_type = accept_header.find { |i| i.start_with?("text/x-bibliography") }
      return nil unless content_type.present?

      hsh = content_type.split("; ").reduce({}) do |sum, i|
        k, v = i.split("=")
        sum[k] = v if v.present?
        sum
      end

      params = { doi: doi_from_url(id),
                 style: hsh["style"] || "apa",
                 locale: hsh["locale"] || "en-US" }

      ENV['CITEPROC_URL'] + "?" + URI.encode_www_form(params)
    end

    def should_redirect_available(id: nil, accept_header: nil)
      content_type = (accept_header & available_content_types.keys).first
      return nil unless content_type.present?

      "/content/" + content_type + "/" + doi_from_url(id)
    end

    def should_pass_thru(id: nil)
      return nil unless validate_doi(id)

      response = Maremma.head id, limit: 0
      response.headers["location"]
    end

    # content-types registered for that DOI
    def get_registered_content_types(id)
      doi = doi_from_url(id)
      media_url = ENV['SEARCH_URL'] + "api?q=doi:#{doi}&fl=doi,media&wt=json"
      response = Maremma.get media_url
      doc = response.body.dig("data", "response", "docs").first
      if doc.present?
        doc.fetch("media", []).reduce({}) do|sum, i|
          content_type, url = i.split(":", 2)
          sum[content_type] = url
          sum
        end
      else
        {}
      end
    end

    # content-types supported by bolognese gem
    def available_content_types
      {
        'application/vnd.datacite.datacite+xml' => 'datacite',
        'application/vnd.datacite.datacite+json' => 'datacite_json',
        'application/vnd.schemaorg.ld+json' => 'schema_org',
        'application/vnd.citationstyles.csl+json' => 'citeproc',
        'application/x-research-info-systems' => 'ris',
        'application/x-bibtex' => 'bibtex'
      }
    end
  end
end

Sinatra::Application.helpers Sinatra::Helpers
