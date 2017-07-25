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
      id = "https://doi.org/10.5061/dryad.8515"
      expect(subject.get_registered_content_types(id)).to eq({})
    end
  end

  describe "available_content_types" do
    it 'should include all mime types' do
      expect(subject.available_content_types).to eq({
        "application/vnd.crosscite.crosscite+json" => :crosscite,
        "application/vnd.crossref.unixref+xml"=>:crossref,
        "application/vnd.datacite.datacite+xml"=>:datacite,
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
end
