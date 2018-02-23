require 'rails_helper'

describe 'redirection', type: :api, vcr: true do
  let(:doi) { "10.4124/ccnwxhx" }

  it "no accept header" do
    get "/#{doi}"

    expect(last_response.status).to eq(303)
    expect(last_response.headers["Location"]).to eq("http://www.ccdc.cam.ac.uk/services/structure_request?id=doi:10.4124/ccnwxhx&sid=DataCite")
  end
end

describe 'content negotiation', type: :api, vcr: true do
  let(:doi) { "10.4124/ccnwxhx" }

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

  context "application/vnd.jats+xml" do
    let(:doi) { "10.7554/elife.01567" }

    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.jats+xml" }

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).dig("element_citation")
      expect(response.dig("pub_id")).to eq("pub_id_type"=>"doi", "__content__"=>"10.7554/elife.01567")
    end

    it "link" do
      get "/application/vnd.jats+xml/#{doi}"

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).dig("element_citation")
      expect(response.dig("pub_id")).to eq("pub_id_type"=>"doi", "__content__"=>"10.7554/elife.01567")
    end
  end

  context "application/vnd.datacite.datacite+xml" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.datacite.datacite+xml" }

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).to_h.fetch("resource", {})
      expect(response.dig("publisher")).to eq("Cambridge Crystallographic Data Centre")
      expect(response.dig("titles", "title")).to eq("CCDC 622650: Experimental Crystal Structure Determination")
    end

    it "link" do
      get "/application/vnd.datacite.datacite+xml/#{doi}"

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).to_h.fetch("resource", {})
      expect(response.dig("publisher")).to eq("Cambridge Crystallographic Data Centre")
      expect(response.dig("titles", "title")).to eq("CCDC 622650: Experimental Crystal Structure Determination")
    end

    it "no metadata" do
      doi = "10.15146/R34015"
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.datacite.datacite+xml" }

      #expect(last_response.status).to eq(404)
      expect(last_response.body).to eq("The resource you are looking for doesn't exist.")
    end
  end

  context "application/vnd.datacite.datacite+json" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.datacite.datacite+json" }

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["id"]).to eq("https://handle.test.datacite.org/10.4124/ccnwxhx")
    end

    it "link" do
      get "/application/vnd.datacite.datacite+json/#{doi}"

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["id"]).to eq("https://handle.test.datacite.org/10.4124/ccnwxhx")
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
      expect(last_response.body).to start_with("@misc{https://handle.test.datacite.org/10.4124/ccnwxhx")
    end

    it "link" do
      get "/application/x-bibtex/#{doi}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("@misc{https://handle.test.datacite.org/10.4124/ccnwxhx")
    end
  end

  context "text/x-bibliography" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "text/x-bibliography" }
      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("Krempner, C., Reinke, H.")
    end

    it "link" do
      get "/text/x-bibliography/#{doi}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("Krempner, C., Reinke, H.")
    end

    it "link with style" do
      get "/text/x-bibliography;style=ieee/#{doi}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("[1]C. Krempner, H.")
    end

    it "link with style and space" do
      get "/text/x-bibliography;+style=ieee/#{doi}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("[1]C. Krempner, H.")
    end

    it "link with style and locale" do
      get "/text/x-bibliography;style=vancouver;locale=de/#{doi}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("1. Krempner C")
    end
  end

  # context "chemical/x-gaussian-log" do
  #   let(:doi) { "10.14469/hpc/678" }
  #
  #   it "header" do
  #     get "/#{doi}", nil, { "HTTP_ACCEPT" => "chemical/x-gaussian-log" }
  #
  #     expect(last_response.status).to eq(303)
  #     response = Maremma.from_xml(last_response.body)
  #     expect(response.dig("html", "body", "a", "href")).to eq("https://data.hpc.imperial.ac.uk/resolve/?doi=678&file=2")
  #   end
  #
  #   it "link" do
  #     get "/chemical/x-gaussian-log/#{doi}"
  #
  #     expect(last_response.status).to eq(303)
  #     response = Maremma.from_xml(last_response.body)
  #     expect(response.dig("html", "body", "a", "href")).to eq("https://data.hpc.imperial.ac.uk/resolve/?doi=678&file=2")
  #   end
  # end

  context "image/png" do
    let(:doi) { "10.4124/12345678987654321" }

    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "image/jpg" }

      expect(last_response.status).to eq(303)
      response = Maremma.from_xml(last_response.body)
      expect(response.dig("html", "body", "a", "href")).to eq("http://www.bl.uk/reshelp/experthelp/science/inspiringscience/2014/NASAPerpetualOcean_lrg.jpg")
    end

    it "link" do
      get "/image/jpg/#{doi}"

      expect(last_response.status).to eq(303)
      response = Maremma.from_xml(last_response.body)
      expect(response.dig("html", "body", "a", "href")).to eq("http://www.bl.uk/reshelp/experthelp/science/inspiringscience/2014/NASAPerpetualOcean_lrg.jpg")
    end
  end

  context "application/xml" do
    let(:doi) { "10.5438/0000-03VC" }

    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/xml" }

      expect(last_response.status).to eq(303)
      response = Maremma.from_xml(last_response.body)
      expect(response.dig("html", "body", "a", "href")).to eq("https://blog.datacite.org/cool-dois/cool-dois.xml")
    end

    it "link" do
      get "/application/xml/#{doi}"

      expect(last_response.status).to eq(303)
      response = Maremma.from_xml(last_response.body)
      expect(response.dig("html", "body", "a", "href")).to eq("https://blog.datacite.org/cool-dois/cool-dois.xml")
    end
  end

  context "unknown accept header" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/xml" }

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("http://www.ccdc.cam.ac.uk/services/structure_request?id=doi:10.4124/ccnwxhx&sid=DataCite")
    end

    it "link" do
      get "/application/xml/#{doi}"

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("http://www.ccdc.cam.ac.uk/services/structure_request?id=doi:10.4124/ccnwxhx&sid=DataCite")
    end
  end
end
