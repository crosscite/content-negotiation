require 'rails_helper'

describe Help do
  describe "get_registered_content_types", vcr: true do
    it 'has registered one content_type' do
      id = "10.0042/FOOBAR3"
      expect(subject.get_registered_content_types(id)).to eq("text/csv" => "http://example.com")
    end

    it 'has registered multiple content_types' do
      id = "10.4124/DEMODATASET4"
      expect(subject.get_registered_content_types(id)).to eq( +"application/pdf" => "http://www.bl.uk/aboutus/stratpolprog/digi/datasets/WorkingWithDataCite_2013.pdf",
        "image/jpeg" => "http://www.bl.uk/reshelp/experthelp/science/sciencetechnologymedicinecollections/researchdatasets/SearchMovieTN.jpg")
    end

    it 'has no registered content_types' do
      id = "https://doi.org/10.4124/ccnwxhx"
      expect(subject.get_registered_content_types(id)).to eq({})
    end
  end

  describe "available_content_types" do
    it 'should include all mime types' do
      expect(subject.available_content_types).to eq({
        "application/vnd.crosscite.crosscite+json" => :crosscite,
        "application/vnd.crossref.unixref+xml"=>:crossref,
        "application/vnd.datacite.datacite+xml"=>:datacite,
        "application/vnd.jats+xml" => :jats,
        "application/x-datacite+xml"=>:datacite,
        "application/vnd.datacite.datacite+json"=>:datacite_json,
        "application/vnd.schemaorg.ld+json"=>:schema_org,
        "application/rdf+xml"=>:rdf_xml,
        "text/turtle"=>:turtle,
        "application/vnd.citationstyles.csl+json"=>:citeproc,
        "application/citeproc+json"=>:citeproc,
        "application/vnd.codemeta.ld+json"=>:codemeta,
        "application/x-bibtex"=>:bibtex,
        "application/x-research-info-systems"=>:ris,
        "text/x-bibliography"=>:citation })
    end
  end

  describe "landing_page_info", vcr: true do
    before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2017, 8, 1, 11, 26)) }
    let(:checked) { "2017-08-01T11:26:00Z" }

    it "status 200" do
      id = "https://handle.test.datacite.org/10.22002/D1.227"
      info = subject.get_landing_page_info(id: id)
      expect(info).to eq("status"=>200, "content-type"=>"text/html", "checked"=>checked)
    end

    it "status 404" do
      id = "https://handle.test.datacite.org/10.0155/1pb0"
      info = subject.get_landing_page_info(id: id)
      expect(info).to eq("status"=>404, "content-type"=>nil, "checked"=>checked)
    end

    it "status 408" do
      id = "https://doi.org/10.5061/dryad.8515x"
      stub = stub_request(:head, id).to_return(:status => [408])
      info = subject.get_landing_page_info(id: id)
      expect(info).to eq("status"=>408, "content-type"=>nil, "checked"=>checked)
    end

    # missing example
    # it "content type not text/html" do
    #   id = "https://handle.test.datacite.org/10.20375/0000-0002-D688-3"
    #   info = subject.get_landing_page_info(id: id)
    #   expect(info).to eq("status"=>200, "content-type"=>"application/x-zip-compressed", "checked"=>checked)
    # end
  end

  describe "media_url_info", vcr: true do
    before(:each) { allow(Time.zone).to receive(:now).and_return(Time.mktime(2017, 8, 1, 11, 26)) }
    let(:checked) { "2017-08-01T11:26:00Z" }

    it "status 200" do
      id = "http://www.bl.uk/pdf/issnappform.pdf"
      media_type = "application/pdf"
      info = subject.get_media_url_info(id: id, media_type: media_type)
      expect(info).to eq("status"=>200, "content-type"=>"application/pdf", "checked"=>checked)
    end

    it "status 408" do
      id = "https://doi.org/10.4124/00001x"
      stub = stub_request(:head, id).to_return(:status => [408])
      info = subject.get_landing_page_info(id: id)
      expect(info).to eq("status"=>408, "content-type"=>nil, "checked"=>checked)
    end
  end
end
