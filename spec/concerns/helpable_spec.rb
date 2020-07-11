require 'rails_helper'

describe Help do
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
        "application/vnd.citationstyles.csl+json"=>:citeproc,
        "application/citeproc+json"=>:citeproc,
        "application/ld+json" => :schema_org,
        "application/vnd.codemeta.ld+json"=>:codemeta,
        "application/x-bibtex" => :bibtex,
        "application/x-research-info-systems"=>:ris,
        "application/rdf+xml" => :rdf_xml,
        "application/x-turtle" => :turtle,
        "text/x-bibliography" =>:citation })
    end
  end
end
