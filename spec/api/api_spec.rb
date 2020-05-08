require 'rails_helper'

describe 'redirection', type: :api, vcr: true do
  let(:doi) { "10.14454/cne7-ar31" }

  it "no accept header" do
    get "/#{doi}"

    expect(last_response.status).to eq(303)
    expect(last_response.headers["Location"]).to eq("https://blog.datacite.org/announcing-schema-4-2/")
  end
end

describe 'content negotiation', type: :api, vcr: true do
  let(:doi) { "10.14454/cne7-ar31" }

  context "application/vnd.jats+xml" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.jats+xml" }

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).dig("element_citation")
      expect(response.dig("pub_id")).to eq("pub_id_type"=>"doi", "__content__"=>"10.14454/CNE7-AR31")
    end

    it "link" do
      get "/application/vnd.jats+xml/#{doi}"

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).dig("element_citation")
      expect(response.dig("pub_id")).to eq("pub_id_type"=>"doi", "__content__"=>"10.14454/CNE7-AR31")
    end
  end

  context "application/vnd.datacite.datacite+xml" do
    let(:doi) { "10.00012/uu01-ltej7x" }

    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.datacite.datacite+xml" }

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).to_h.fetch("resource", {})
      expect(response.dig("publisher")).to eq("Utrecht University")
      expect(response.dig("titles", "title")).to eq("__content__"=>"Minimum: Title", "xml:lang"=>"en")
      expect(response.dig("version")).to eq("Minimum: Version")
    end

    it "link" do
      get "/application/vnd.datacite.datacite+xml/#{doi}"

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).to_h.fetch("resource", {})
      expect(response.dig("publisher")).to eq("Utrecht University")
      expect(response.dig("titles", "title")).to eq("__content__"=>"Minimum: Title", "xml:lang"=>"en")
      expect(response.dig("version")).to eq("Minimum: Version")
    end

    it "not found" do
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
      expect(response["id"]).to eq("https://doi.org/10.14454/cne7-ar31")
    end

    it "link" do
      get "/application/vnd.datacite.datacite+json/#{doi}"

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["id"]).to eq("https://doi.org/10.14454/cne7-ar31")
    end
  end

  context "application/vnd.schemaorg.ld+json" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.schemaorg.ld+json" }

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["@type"]).to eq("BlogPosting")
    end

    it "link" do
      get "/application/vnd.schemaorg.ld+json/#{doi}"

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["@type"]).to eq("BlogPosting")
    end
  end

  context "application/ld+json" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/ld+json" }

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["@type"]).to eq("BlogPosting")
    end

    it "link" do
      get "/application/ld+json/#{doi}"

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["@type"]).to eq("BlogPosting")
    end
  end

  context "application/vnd.citationstyles.csl+json" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.citationstyles.csl+json" }

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["type"]).to eq("post-weblog")
    end

    it "link" do
      get "/application/vnd.citationstyles.csl+json/#{doi}"

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["type"]).to eq("post-weblog")
    end

    # it "doi with + character" do
    #   doi = "10.14454/terra+aqua/ceres/cldtyphist_l3.004"
    #   get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.citationstyles.csl+json" }

    #   expect(last_response.status).to eq(200)
    #   response = JSON.parse(last_response.body)
    #   expect(response["type"]).to eq("dataset")
    # end
  end

  context "application/x-research-info-systems" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/x-research-info-systems" }

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("TY  - GEN")
    end

    it "link" do
      get "/application/x-research-info-systems/#{doi}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("TY  - GEN")
    end
  end

  context "application/x-bibtex" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/x-bibtex" }

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("@article{https://doi.org/10.14454/cne7-ar31")
    end

    it "link" do
      get "/application/x-bibtex/#{doi}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("@article{https://doi.org/10.14454/cne7-ar31")
    end
  end

  # context "application/rdf+xml" do
  #   it "header" do
  #     get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/rdf+xml" }

  #     expect(last_response.status).to eq(200)
  #     rdfxml = Maremma.from_xml(last_response.body).fetch("RDF", {})
  #     expect(rdfxml.dig("BlogPosting", "rdf:about")).to eq("https://doi.org/10.14454/cne7-ar31")   
  #   end

  #   it "link" do
  #     get "/application/rdf+xml/#{doi}"

  #     expect(last_response.status).to eq(200)
  #     rdfxml = Maremma.from_xml(last_response.body).fetch("RDF", {})
  #     expect(rdfxml.dig("BlogPosting", "rdf:about")).to eq("https://doi.org/10.14454/cne7-ar31")   
  #   end
  # end

  # context "application/x-turtle" do
  #   it "header" do
  #     get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/x-turtle" }

  #     expect(last_response.status).to eq(200)
  #     ttl = last_response.body.split("\n")
  #     expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
  #     expect(ttl[2]).to eq("<https://doi.org/10.14454/cne7-ar31> a schema:BlogPosting;")
  #   end

  #   it "link" do
  #     get "/application/x-turtle/#{doi}"

  #     expect(last_response.status).to eq(200)
  #     ttl = last_response.body.split("\n")
  #     expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
  #     expect(ttl[2]).to eq("<https://doi.org/10.14454/cne7-ar31> a schema:BlogPosting;")
  #   end
  # end

  context "text/x-bibliography" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "text/x-bibliography" }
      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("Dasler, R., &amp; de Smaele, M.")
    end

    it "link" do
      get "/text/x-bibliography/#{doi}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("Dasler, R., &amp; de Smaele, M.")
    end

    it "link with style" do
      get "/text/x-bibliography/#{doi}?style=ieee"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("R. Dasler and")
    end

    it "link with style and locale" do
      get "/text/x-bibliography/#{doi}?style=vancouver&locale=de"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("Dasler R")
    end

    it "link with style not found" do
      get "/text/x-bibliography/#{doi}?style=mla"

      # falling back to default APA style
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("Dasler, R., &amp; de Smaele, M. (2019, March 20). <i>Announcing schema 4.2</i>. https://doi.org/10.14454/CNE7-AR31")
    end
  end

  context "unknown accept header" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/xml" }

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("https://blog.datacite.org/announcing-schema-4-2/")
    end

    it "link" do
      get "/application/xml/#{doi}"

      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq("The resource you are looking for doesn't exist.")
    end
  end

  context "registration agency op in datacite index" do
    let (:doi) { "10.2899/caricom/1" }

    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.datacite.datacite+xml" }

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).to_h.fetch("resource", {})
      expect(response.dig("publisher")).to eq("Publications Office")
      expect(response.dig("titles", "title")).to eq("__content__"=>"OP DOI RA Test", "xml:lang"=>"en")
    end

    it "link" do
      get "/application/vnd.datacite.datacite+xml/#{doi}"

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).to_h.fetch("resource", {})
      expect(response.dig("publisher")).to eq("Publications Office")
      expect(response.dig("titles", "title")).to eq("__content__"=>"OP DOI RA Test", "xml:lang"=>"en")
    end
  end

  context "registration agency op" do
    let (:doi) { "10.2788/011817" }

    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/xml" }

      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq("The resource you are looking for doesn't exist.")
    end

    it "link" do
      get "/application/xml/#{doi}"

      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq("The resource you are looking for doesn't exist.")
    end
  end
end

describe 'content negotiation crossref', type: :api, vcr: true do
  let(:doi) { "10.7554/elife.01567" }

  context "application/vnd.crossref.unixref+xml" do
    let(:doi) { "10.7554/elife.01567" }

    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.crossref.unixref+xml" }

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).dig("crossref_result", "query_result", "body", "query", "doi_record")
      expect(response.dig("crossref", "journal", "journal_article", "doi_data", "doi")).to eq("10.7554/eLife.01567")
    end

    it "link" do
      get "/application/vnd.crossref.unixref+xml/#{doi}"

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).dig("crossref_result", "query_result", "body", "query", "doi_record")
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
      expect(response.dig("publisher")).to eq("eLife Sciences Publications, Ltd")
      expect(response.dig("titles", "title")).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
    end

    it "link" do
      get "/application/vnd.datacite.datacite+xml/#{doi}"

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).to_h.fetch("resource", {})
      expect(response.dig("publisher")).to eq("eLife Sciences Publications, Ltd")
      expect(response.dig("titles", "title")).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
    end

    it "not found" do
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
      expect(response["id"]).to eq("https://doi.org/10.7554/elife.01567")
    end

    it "link" do
      get "/application/vnd.datacite.datacite+json/#{doi}"

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["id"]).to eq("https://doi.org/10.7554/elife.01567")
    end
  end

  context "application/vnd.schemaorg.ld+json" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.schemaorg.ld+json" }

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["@type"]).to eq("ScholarlyArticle")
    end

    it "link" do
      get "/application/vnd.schemaorg.ld+json/#{doi}"

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["@type"]).to eq("ScholarlyArticle")
    end
  end

  context "application/ld+json" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/ld+json" }

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["@type"]).to eq("ScholarlyArticle")
    end

    it "link" do
      get "/application/ld+json/#{doi}"

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["@type"]).to eq("ScholarlyArticle")
    end
  end

  context "application/vnd.citationstyles.csl+json" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.citationstyles.csl+json" }

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["type"]).to eq("article-journal")
    end

    it "link" do
      get "/application/vnd.citationstyles.csl+json/#{doi}"

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["type"]).to eq("article-journal")
    end

    # it "doi with + character" do
    #   doi = "10.14454/terra+aqua/ceres/cldtyphist_l3.004"
    #   get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.citationstyles.csl+json" }

    #   expect(last_response.status).to eq(200)
    #   response = JSON.parse(last_response.body)
    #   expect(response["type"]).to eq("dataset")
    # end
  end

  context "application/x-research-info-systems" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/x-research-info-systems" }

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("TY  - JOUR")
    end

    it "link" do
      get "/application/x-research-info-systems/#{doi}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("TY  - JOUR")
    end
  end

  context "application/x-bibtex" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/x-bibtex" }

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("@article{https://doi.org/10.7554/elife.01567")
    end

    it "link" do
      get "/application/x-bibtex/#{doi}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("@article{https://doi.org/10.7554/elife.01567")
    end
  end

  # context "application/rdf+xml" do
  #   it "header" do
  #     get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/rdf+xml" }

  #     expect(last_response.status).to eq(200)
  #     rdfxml = Maremma.from_xml(last_response.body).fetch("RDF", {})
  #     expect(rdfxml.dig("ScholarlyArticle", "rdf:about")).to eq("https://doi.org/10.7554/elife.01567")   
  #   end

  #   it "link" do
  #     get "/application/rdf+xml/#{doi}"

  #     expect(last_response.status).to eq(200)
  #     rdfxml = Maremma.from_xml(last_response.body).fetch("RDF", {})
  #     expect(rdfxml.dig("ScholarlyArticle", "rdf:about")).to eq("https://doi.org/10.7554/elife.01567")   
  #   end
  # end

  # context "application/x-turtle" do
  #   it "header" do
  #     get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/x-turtle" }

  #     expect(last_response.status).to eq(200)
  #     ttl = last_response.body.split("\n")
  #     expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
  #     expect(ttl[2]).to eq("<https://doi.org/10.7554/elife.01567> a schema:ScholarlyArticle;")
  #   end

  #   it "link" do
  #     get "/application/x-turtle/#{doi}"

  #     expect(last_response.status).to eq(200)
  #     ttl = last_response.body.split("\n")
  #     expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
  #     expect(ttl[2]).to eq("<https://doi.org/10.7554/elife.01567> a schema:ScholarlyArticle;")
  #   end
  # end

  context "text/x-bibliography" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "text/x-bibliography" }
      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("Sankar, M., Nieminen, K.")
    end

    it "header with style" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "text/x-bibliography; style=ieee" }
      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("M. Sankar, K. Nieminen")
    end

    it "header with style and locale" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "text/x-bibliography; style=vancouver; locale=de" }
      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("Sankar M")
    end

    it "link" do
      get "/text/x-bibliography/#{doi}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("Sankar, M., Nieminen, K.")
    end

    it "link with style" do
      get "/text/x-bibliography/#{doi}?style=ieee"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("M. Sankar, K. Nieminen")
    end

    it "link with style and locale" do
      get "/text/x-bibliography/#{doi}?style=vancouver&locale=de"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("Sankar M")
    end

    it "link with style not found" do
      get "/text/x-bibliography/#{doi}?style=mla"

      # falling back to default APA style
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("Sankar, M., Nieminen, K., Ragni, L., Xenarios, I., &amp; Hardtke, C. S. (2014). Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth. <i>ELife</i>, <i>3</i>. https://doi.org/10.7554/elife.01567")
    end
  end

  context "unknown accept header" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/xml" }

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("https://elifesciences.org/articles/01567")
    end

    it "link" do
      get "/application/xml/#{doi}"

      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq("The resource you are looking for doesn't exist.")
    end
  end
end

describe 'content negotiation medra', type: :api, vcr: true do
  let(:doi) { "10.1393/ncc/i2016-16378-6" }

  context "application/vnd.jats+xml" do

    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.jats+xml" }

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).dig("element_citation")
      expect(response.dig("pub_id")).to eq("__content__"=>"10.1393/ncc/i2016-16378-6", "pub_id_type"=>"doi")
    end

    it "link" do
      get "/application/vnd.jats+xml/#{doi}"

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).dig("element_citation")
      expect(response.dig("pub_id")).to eq("__content__"=>"10.1393/ncc/i2016-16378-6", "pub_id_type"=>"doi")
    end
  end

  context "application/vnd.datacite.datacite+xml" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.datacite.datacite+xml" }

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).to_h.fetch("resource", {})
      expect(response.dig("publisher")).to eq("SIF")
      expect(response.dig("titles", "title")).to eq("Probing the nuclear symmetry energy at high densities with nuclear reactions")
    end

    it "link" do
      get "/application/vnd.datacite.datacite+xml/#{doi}"

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).to_h.fetch("resource", {})
      expect(response.dig("publisher")).to eq("SIF")
      expect(response.dig("titles", "title")).to eq("Probing the nuclear symmetry energy at high densities with nuclear reactions")
    end

    it "not found" do
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
      expect(response["id"]).to eq("https://doi.org/10.1393/ncc/i2016-16378-6")
    end

    it "link" do
      get "/application/vnd.datacite.datacite+json/#{doi}"

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["id"]).to eq("https://doi.org/10.1393/ncc/i2016-16378-6")
    end
  end

  context "application/vnd.schemaorg.ld+json" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.schemaorg.ld+json" }

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["@type"]).to eq("ScholarlyArticle")
    end

    it "link" do
      get "/application/vnd.schemaorg.ld+json/#{doi}"

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["@type"]).to eq("ScholarlyArticle")
    end
  end

  context "application/vnd.citationstyles.csl+json" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.citationstyles.csl+json" }

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["type"]).to eq("article-journal")
    end

    it "link" do
      get "/application/vnd.citationstyles.csl+json/#{doi}"

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["type"]).to eq("article-journal")
    end

    # it "doi with + character" do
    #   doi = "10.14454/terra+aqua/ceres/cldtyphist_l3.004"
    #   get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.citationstyles.csl+json" }

    #   expect(last_response.status).to eq(200)
    #   response = JSON.parse(last_response.body)
    #   expect(response["type"]).to eq("dataset")
    # end
  end

  context "application/x-research-info-systems" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/x-research-info-systems" }

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("TY  - GEN")
    end

    it "link" do
      get "/application/x-research-info-systems/#{doi}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("TY  - GEN")
    end
  end

  context "application/x-bibtex" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/x-bibtex" }

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("@article{https://doi.org/10.1393/ncc/i2016-16378-6")
    end

    it "link" do
      get "/application/x-bibtex/#{doi}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("@article{https://doi.org/10.1393/ncc/i2016-16378-6")
    end
  end

  # context "application/rdf+xml" do
  #   it "header" do
  #     get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/rdf+xml" }

  #     expect(last_response.status).to eq(200)
  #     rdfxml = Maremma.from_xml(last_response.body).fetch("RDF", {})
  #     expect(rdfxml.dig("ScholarlyArticle", "rdf:about")).to eq("https://doi.org/10.1393/ncc/i2016-16378-6")   
  #   end

  #   it "link" do
  #     get "/application/rdf+xml/#{doi}"

  #     expect(last_response.status).to eq(200)
  #     rdfxml = Maremma.from_xml(last_response.body).fetch("RDF", {})
  #     expect(rdfxml.dig("ScholarlyArticle", "rdf:about")).to eq("https://doi.org/10.1393/ncc/i2016-16378-6")   
  #   end
  # end

  # context "application/x-turtle" do
  #   it "header" do
  #     get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/x-turtle" }

  #     expect(last_response.status).to eq(200)
  #     ttl = last_response.body.split("\n")
  #     expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
  #     expect(ttl[2]).to eq("<https://doi.org/10.1393/ncc/i2016-16378-6> a schema:ScholarlyArticle;")
  #   end

  #   it "link" do
  #     get "/application/x-turtle/#{doi}"

  #     expect(last_response.status).to eq(200)
  #     ttl = last_response.body.split("\n")
  #     expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
  #     expect(ttl[2]).to eq("<https://doi.org/10.1393/ncc/i2016-16378-6> a schema:ScholarlyArticle;")
  #   end
  # end

  context "text/x-bibliography" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "text/x-bibliography" }
      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("Probing the nuclear symmetry energy")
    end

    it "link" do
      get "/text/x-bibliography/#{doi}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("Probing the nuclear symmetry energy")
    end

    it "link with style" do
      get "/text/x-bibliography/#{doi}?style=ieee"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("“Probing the nuclear symmetry energy at high densities with nuclear reactions,” <i>Il Nuovo Cimento C</i>, vol. 39, no. 6, pp. 1–10, Mar. 2017, doi: 10.1393/ncc/i2016-16378-6.")
    end

    it "link with style and locale" do
      get "/text/x-bibliography/#{doi}?style=vancouver&locale=de"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("Probing the nuclear symmetry energy")
    end

    it "link with style not found" do
      get "/text/x-bibliography/#{doi}?style=mla"

      # falling back to default APA style
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("Probing the nuclear symmetry energy at high densities with nuclear reactions. (2017). <i>Il Nuovo Cimento C</i>, <i>39</i>(6), 1–10. https://doi.org/10.1393/ncc/i2016-16378-6")
    end
  end

  context "unknown accept header" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/xml" }

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("https://doi.org/10.1393/ncc/i2016-16378-6")
    end

    it "link" do
      get "/application/xml/#{doi}"

      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq("The resource you are looking for doesn't exist.")
    end
  end
end

describe 'content negotiation jalc', type: :api, vcr: true do
  let(:doi) { "10.18942/apg.201812" }

  context "application/vnd.jats+xml" do

    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.jats+xml" }

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).dig("element_citation")
      expect(response.dig("pub_id")).to eq("__content__"=>"10.18942/apg.201812", "pub_id_type"=>"doi")
    end

    it "link" do
      get "/application/vnd.jats+xml/#{doi}"

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).dig("element_citation")
      expect(response.dig("pub_id")).to eq("__content__"=>"10.18942/apg.201812", "pub_id_type"=>"doi")
    end
  end

  context "application/vnd.datacite.datacite+xml" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.datacite.datacite+xml" }

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).to_h.fetch("resource", {})
      expect(response.dig("publisher")).to eq("The Japanese Society for Plant Systematics")
      expect(response.dig("titles", "title")).to eq("Allopolyploid Origin and Distribution Range of <i>Acystopteris taiwaniana </i>(Cystopteridaceae: Polypodiales)")
    end

    it "link" do
      get "/application/vnd.datacite.datacite+xml/#{doi}"

      expect(last_response.status).to eq(200)
      response = Maremma.from_xml(last_response.body).to_h.fetch("resource", {})
      expect(response.dig("publisher")).to eq("The Japanese Society for Plant Systematics")
      expect(response.dig("titles", "title")).to eq("Allopolyploid Origin and Distribution Range of <i>Acystopteris taiwaniana </i>(Cystopteridaceae: Polypodiales)")
    end

    it "not found" do
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
      expect(response["id"]).to eq("https://doi.org/10.18942/apg.201812")
    end

    it "link" do
      get "/application/vnd.datacite.datacite+json/#{doi}"

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["id"]).to eq("https://doi.org/10.18942/apg.201812")
    end
  end

  context "application/vnd.schemaorg.ld+json" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.schemaorg.ld+json" }

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["@type"]).to eq("CreativeWork")
    end

    it "link" do
      get "/application/vnd.schemaorg.ld+json/#{doi}"

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["@type"]).to eq("CreativeWork")
    end
  end

  context "application/vnd.citationstyles.csl+json" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.citationstyles.csl+json" }

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["title"]).to eq("Allopolyploid Origin and Distribution Range of <i>Acystopteris taiwaniana </i>(Cystopteridaceae: Polypodiales)")
    end

    it "link" do
      get "/application/vnd.citationstyles.csl+json/#{doi}"

      expect(last_response.status).to eq(200)
      response = JSON.parse(last_response.body)
      expect(response["title"]).to eq("Allopolyploid Origin and Distribution Range of <i>Acystopteris taiwaniana </i>(Cystopteridaceae: Polypodiales)")
    end

    # it "doi with + character" do
    #   doi = "10.14454/terra+aqua/ceres/cldtyphist_l3.004"
    #   get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/vnd.citationstyles.csl+json" }

    #   expect(last_response.status).to eq(200)
    #   response = JSON.parse(last_response.body)
    #   expect(response["type"]).to eq("dataset")
    # end
  end

  context "application/x-research-info-systems" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/x-research-info-systems" }

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("TY  - GEN")
    end

    it "link" do
      get "/application/x-research-info-systems/#{doi}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("TY  - GEN")
    end
  end

  context "application/x-bibtex" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/x-bibtex" }

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("@misc{https://doi.org/10.18942/apg.201812")
    end

    it "link" do
      get "/application/x-bibtex/#{doi}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("@misc{https://doi.org/10.18942/apg.201812")
    end
  end

  # context "application/rdf+xml" do
  #   it "header" do
  #     get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/rdf+xml" }

  #     expect(last_response.status).to eq(200)
  #     rdfxml = Maremma.from_xml(last_response.body).fetch("RDF", {})
  #     expect(rdfxml.dig("CreativeWork", "rdf:about")).to eq("https://doi.org/10.18942/apg.201812")   
  #   end

  #   it "link" do
  #     get "/application/rdf+xml/#{doi}"

  #     expect(last_response.status).to eq(200)
  #     rdfxml = Maremma.from_xml(last_response.body).fetch("RDF", {})
  #     expect(rdfxml.dig("CreativeWork", "rdf:about")).to eq("https://doi.org/10.18942/apg.201812")   
  #   end
  # end

  # context "application/x-turtle" do
  #   it "header" do
  #     get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/x-turtle" }

  #     expect(last_response.status).to eq(200)
  #     ttl = last_response.body.split("\n")
  #     expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
  #     expect(ttl[2]).to eq("<https://doi.org/10.18942/apg.201812> a schema:CreativeWork;")
  #   end

  #   it "link" do
  #     get "/application/x-turtle/#{doi}"

  #     expect(last_response.status).to eq(200)
  #     ttl = last_response.body.split("\n")
  #     expect(ttl[0]).to eq("@prefix schema: <http://schema.org/> .")
  #     expect(ttl[2]).to eq("<https://doi.org/10.18942/apg.201812> a schema:CreativeWork;")
  #   end
  # end

  context "text/x-bibliography" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "text/x-bibliography" }
      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("Ebihara, A., Nakato, N.")
    end

    it "link" do
      get "/text/x-bibliography/#{doi}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("Ebihara, A., Nakato, N.")
    end

    it "link with style" do
      get "/text/x-bibliography/#{doi}?style=ieee"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to start_with("A. Ebihara, N. Nakato")
    end

    it "link with style and locale" do
      get "/text/x-bibliography/#{doi}?style=vancouver&locale=de"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("Ebihara A, Nakato N, Kuo L-Y, Miyazaki H, Serizawa S. Allopolyploid Origin and Distribution Range of <i>Acystopteris taiwaniana </i>(Cystopteridaceae: Polypodiales) [Internet]. Bd. 70, Acta phytotaxonomica et geobotanica. The Japanese Society for Plant Systematics; 2019. S. 19–28. Verfügbar unter: https://doi.org/10.18942/apg.201812")
    end

    it "link with style not found" do
      get "/text/x-bibliography/#{doi}?style=mla"

      # falling back to default APA style
      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("Ebihara, A., Nakato, N., Kuo, L.-Y., Miyazaki, H., &amp; Serizawa, S. (2019). Allopolyploid Origin and Distribution Range of <i>Acystopteris taiwaniana </i>(Cystopteridaceae: Polypodiales). In <i>Acta phytotaxonomica et geobotanica</i> (Vol. 70, pp. 19–28). The Japanese Society for Plant Systematics. https://doi.org/10.18942/apg.201812")
    end
  end

  context "unknown accept header" do
    it "header" do
      get "/#{doi}", nil, { "HTTP_ACCEPT" => "application/xml" }

      expect(last_response.status).to eq(303)
      expect(last_response.headers["Location"]).to eq("https://doi.org/10.18942/apg.201812")
    end

    it "link" do
      get "/application/xml/#{doi}"

      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq("The resource you are looking for doesn't exist.")
    end
  end

  describe 'rmethod not allowed error', type: :api do
    let(:doi) { "10.14454/cne7-ar31" }
  
    it "post" do
      post "/#{doi}"
  
      expect(last_response.status).to eq(405)
      expect(last_response.body).to eq("Method not allowed.")
    end
  end
end
