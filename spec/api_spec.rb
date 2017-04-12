require 'spec_helper'

describe 'content negotiation', vcr: true do
  context "application/vnd.datacite.datacite+xml" do
    it "header" do
      get '/10.5061/dryad.8515', nil, { "HTTP_ACCEPT" => "application/vnd.datacite.datacite+xml" }

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("http://example.org/content/application/vnd.datacite.datacite+xml/10.5061/dryad.8515")
    end

    it "link" do
      get '/application/vnd.datacite.datacite+xml/10.5061/dryad.8515'

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("http://example.org/content/application/vnd.datacite.datacite+xml/10.5061/dryad.8515")
    end

    it "redirect" do
      get '/content/application/vnd.datacite.datacite+xml/10.5061/dryad.8515'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("http://example.org/content/application/vnd.datacite.datacite+xml/10.5061/dryad.8515")
    end
  end

  context "application/vnd.datacite.datacite+xml" do
    it "header" do
      get '/10.5061/dryad.8515', nil, { "HTTP_ACCEPT" => "application/vnd.datacite.datacite+xml" }

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("http://example.org/content/application/vnd.datacite.datacite+xml/10.5061/dryad.8515")
    end

    it "link" do
      get '/application/vnd.datacite.datacite+xml/10.5061/dryad.8515'

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("http://example.org/content/application/vnd.datacite.datacite+xml/10.5061/dryad.8515")
    end

    it "redirect" do
      get '/content/application/vnd.datacite.datacite+xml/10.5061/dryad.8515'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("")
    end
  end

  context "application/vnd.datacite.datacite+json" do
    it "header" do
      get '/10.5061/dryad.8515', nil, { "HTTP_ACCEPT" => "application/vnd.datacite.datacite+json" }

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("http://example.org/content/application/vnd.datacite.datacite+json/10.5061/dryad.8515")
    end

    it "link" do
      get '/application/vnd.datacite.datacite+json/10.5061/dryad.8515'

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("http://example.org/content/application/vnd.datacite.datacite+json/10.5061/dryad.8515")
    end

    it "redirect" do
      get '/content/application/vnd.datacite.datacite+json/10.5061/dryad.8515'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("")
    end
  end

  context "application/vnd.schemaorg.ld+json" do
    it "header" do
      get '/10.5061/dryad.8515', nil, { "HTTP_ACCEPT" => "application/vnd.schemaorg.ld+json" }

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("http://example.org/content/application/vnd.schemaorg.ld+json/10.5061/dryad.8515")
    end

    it "link" do
      get '/application/vnd.schemaorg.ld+json/10.5061/dryad.8515'

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("http://example.org/content/application/vnd.schemaorg.ld+json/10.5061/dryad.8515")
    end

    it "redirect" do
      get '/content/application/vnd.schemaorg.ld+json/10.5061/dryad.8515'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("")
    end
  end

  context "application/vnd.citationstyles.csl+json" do
    it "header" do
      get '/10.5061/dryad.8515', nil, { "HTTP_ACCEPT" => "application/vnd.citationstyles.csl+json" }

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("http://example.org/content/application/vnd.citationstyles.csl+json/10.5061/dryad.8515")
    end

    it "link" do
      get '/application/vnd.citationstyles.csl+json/10.5061/dryad.8515'

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("http://example.org/content/application/vnd.citationstyles.csl+json/10.5061/dryad.8515")
    end

    it "redirect" do
      get '/content/application/vnd.citationstyles.csl+json/10.5061/dryad.8515'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("")
    end
  end

  context "application/x-research-info-systems" do
    it "header" do
      get '/10.5061/dryad.8515', nil, { "HTTP_ACCEPT" => "application/x-research-info-systems" }

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("http://example.org/content/application/x-research-info-systems/10.5061/dryad.8515")
    end

    it "link" do
      get '/application/x-research-info-systems/10.5061/dryad.8515'

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("http://example.org/content/application/x-research-info-systems/10.5061/dryad.8515")
    end

    it "redirect" do
      get '/content/application/x-research-info-systems/10.5061/dryad.8515'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("")
    end
  end

  context "application/x-bibtex" do
    it "header" do
      get '/10.5061/dryad.8515', nil, { "HTTP_ACCEPT" => "application/x-bibtex" }

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("http://example.org/content/application/x-bibtex/10.5061/dryad.8515")
    end

    it "link" do
      get '/application/x-bibtex/10.5061/dryad.8515'

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("http://example.org/content/application/x-bibtex/10.5061/dryad.8515")
    end

    it "redirect" do
      get '/content/application/x-bibtex/10.5061/dryad.8515'

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("")
    end
  end
end
