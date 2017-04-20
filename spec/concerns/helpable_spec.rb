require 'rails_helper'

describe Metadata do
  describe "get_registered_content_types", vcr: true do
    it 'has registered one content_type' do
      id = "https://doi.org/10.5284/1015681"
      expect(subject.get_registered_content_types(id)).to eq("application/pdf"=>"http://archaeologydataservice.ac.uk/catalogue/adsdata/arch-1045-1/dissemination/pdf/356_ThewatertreatmentplantSaltersfordGrantham_Little.pdf")
    end

    it 'has no registered content_types' do
      id = "https://doi.org/10.5061/dryad.8515"
      expect(subject.get_registered_content_types(id)).to eq({})
    end
  end

  describe "available_content_types" do
    it 'should include all mime types' do
      expect(subject.available_content_types).to eq({
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