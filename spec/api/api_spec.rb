require 'rails_helper'

describe 'redirection', type: :api, vcr: true do
  let(:doi) { "10.5061/dryad.8515" }

  it "no accept header" do
    get "/#{doi}"

    expect(last_response.status).to eq(303)
    expect(last_response.headers["Location"]).to eq("http://datadryad.org/resource/doi:10.5061/dryad.8515")
  end
end

describe 'content negotiation', type: :api, vcr: true do
  let(:doi) { "10.5061/dryad.8515" }

  context "application/vnd.crossref.unixref+xml" do
    let(:doi) { "10.7554/elife.01567" }

    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.crossref.unixref+xml" }

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).dig("doi_records", "doi_record")
      expect(response.dig("crossref", "journal", "journal_article", "doi_data", "doi")).to eq("10.7554/eLife.01567")
    end

    it "link" do
      get "/application/vnd.crossref.unixref+xml/#{doi}"

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).dig("doi_records", "doi_record")
      expect(response.dig("crossref", "journal", "journal_article", "doi_data", "doi")).to eq("10.7554/eLife.01567")
    end
  end

  context "application/vnd.datacite.datacite+xml" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.datacite.datacite+xml" }

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).fetch("resource", {})
      expect(response.dig("titles", "title")).to eq("Data from: A new malaria agent in African hominids.")
    end

    it "link" do
      get "/application/vnd.datacite.datacite+xml/#{doi}"

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).fetch("resource", {})
      expect(response.dig("titles", "title")).to eq("Data from: A new malaria agent in African hominids.")
    end

    it "no metadata" do
      doi = "10.15146/R34015"
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.datacite.datacite+xml" }

      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq("The resource you are looking for doesn't exist.")
    end
  end

  context "application/vnd.datacite.datacite+json" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.datacite.datacite+json" }

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["id"]).to eq("https://doi.org/10.5061/dryad.8515")
    end

    it "link" do
      get "/application/vnd.datacite.datacite+json/#{doi}"

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["id"]).to eq("https://doi.org/10.5061/dryad.8515")
    end
  end

  context "application/vnd.schemaorg.ld+json" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.schemaorg.ld+json" }

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["@type"]).to eq("Dataset")
    end

    it "link" do
      get "/application/vnd.schemaorg.ld+json/#{doi}"

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["@type"]).to eq("Dataset")
    end
  end

  context "application/vnd.citationstyles.csl+json" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.citationstyles.csl+json" }

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["type"]).to eq("dataset")
    end

    it "link" do
      get "/application/vnd.citationstyles.csl+json/#{doi}"

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["type"]).to eq("dataset")
    end
  end

  context "application/x-research-info-systems" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/x-research-info-systems" }

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("TY - DATA")
    end

    it "link" do
      get "/application/x-research-info-systems/#{doi}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("TY - DATA")
    end
  end

  context "application/x-bibtex" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/x-bibtex" }

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("@misc{https://doi.org/10.5061/dryad.8515")
    end

    it "link" do
      get "/application/x-bibtex/#{doi}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("@misc{https://doi.org/10.5061/dryad.8515")
    end
  end

  context "unknown accept header" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/xml" }

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("http://datadryad.org/resource/doi:10.5061/dryad.8515")
    end

    it "link" do
      get "/application/xml/#{doi}"

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("http://datadryad.org/resource/doi:10.5061/dryad.8515")
    end
  end
end
