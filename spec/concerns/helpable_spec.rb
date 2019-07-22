require 'rails_helper'

describe Help do
  describe "get_registered_content_types", vcr: true do
    it 'has registered one content_type' do
      id = "10.70043/4K3M-NYVG7"
      expect(subject.get_registered_content_types(id)).to eq("image/jpeg"=>"https://upload.wikimedia.org/wikipedia/en/a/a9/Example.jpg")
    end

    it 'has registered multiple content_types' do
      id = "10.4224/CRM.2010E.NIMS-1"
      expect(subject.get_registered_content_types(id)).to eq("application/pdf"=>"http://dr-dn.cisti-icist.nrc-cnrc.gc.ca", "text/csv"=>"http://dr-dn.cisti-icist.nrc-cnrc.gc.ca/eng/view/object/?id=cf5ae3c0-f74a-4a4b-bda9-e9b83c239430")
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
        "application/vnd.citationstyles.csl+json"=>:citeproc,
        "application/citeproc+json"=>:citeproc,
        "application/vnd.codemeta.ld+json"=>:codemeta,
        "application/x-bibtex" => :bibtex,
        "application/x-research-info-systems"=>:ris,
        "application/rdf+xml" => :rdf_xml,
        "application/x-turtle" => :turtle,
        "text/x-bibliography" =>:citation })
    end
  end
end
