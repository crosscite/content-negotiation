require 'spec_helper'

describe "Helpers", type: :model, vcr: true do
  let(:fixture_path) { "#{Sinatra::Application.root}/spec/fixtures/" }
  subject { ContentNegotiation.new }

  context "normalize_id" do
    it "doi" do
      id = subject.normalize_id("10.5061/DRYAD.8515")
      expect(id).to eq("https://doi.org/10.5061/dryad.8515")
    end

    it "http dx.doi.org" do
      id = subject.normalize_id("http://dx.doi.org/10.5284/1015681")
      expect(id).to eq("https://doi.org/10.5284/1015681")
    end
  end

  context "doi_from_url" do
    it "url" do
      doi = subject.doi_from_url("https://doi.org/10.5061/dryad.8515")
      expect(doi).to eq("10.5061/dryad.8515")
    end

    it "doi" do
      doi = subject.doi_from_url("10.5061/dryad.8515")
      expect(doi).to eq("10.5061/dryad.8515")
    end

    it "not a doi" do
      doi = subject.doi_from_url("https://doi.org/10.5061")
      expect(doi).to be nil
    end
  end

  context "get_registered_content_types" do
    it "present" do
      content_types = subject.get_registered_content_types("https://doi.org/10.5284/1015681")
      expect(content_types).to eq("application/pdf" => "http://archaeologydataservice.ac.uk/catalogue/adsdata/arch-1045-1/dissemination/pdf/356_ThewatertreatmentplantSaltersfordGrantham_Little.pdf")
    end

    it "absent" do
      content_types= subject.get_registered_content_types("https://doi.org/10.5061/dryad.8515")
      expect(content_types).to be_empty
    end
  end

  context "redirect_by_content_type" do
    it "registered content_type" do
      id = "https://doi.org/10.5284/1015681"
      accept_header = ["application/pdf"]
      redirect_url = subject.redirect_by_content_type(id: id, accept_header: accept_header)
      expect(redirect_url).to eq("http://archaeologydataservice.ac.uk/catalogue/adsdata/arch-1045-1/dissemination/pdf/356_ThewatertreatmentplantSaltersfordGrantham_Little.pdf")
    end

    it "available content_type" do
      id = "https://doi.org/10.5438/0000-0C2G"
      accept_header = ["application/vnd.datacite.datacite+xml"]
      redirect_url = subject.redirect_by_content_type(id: id, accept_header: accept_header)
      expect(redirect_url).to eq("/content/application/vnd.datacite.datacite+xml/10.5438/0000-0c2g")
    end

    it "citation" do
      id = "https://doi.org/10.5438/0000-0C2G"
      accept_header = ["text/x-bibliography; style=modern-language-association-8th-edition; locale=fr-FR"]
      redirect_url = subject.should_redirect_citation(id: id, accept_header: accept_header)
      expect(redirect_url).to eq("#{ENV['CITEPROC_URL']}?doi=10.5438%2F0000-0c2g&style=modern-language-association-8th-edition&locale=fr-FR")
    end

    it "unsupported content_type" do
      id = "https://doi.org/10.5438/0000-0C2G"
      accept_header = ["application/vnd.crossref.unixref+xml"]
      redirect_url = subject.redirect_by_content_type(id: id, accept_header: accept_header)
      expect(redirect_url).to eq("https://blog.datacite.org/oi-project-underway-for-open-org-id-registry/")
    end
  end

  context "should_pass_thru" do
    it "doi" do
      url = subject.should_pass_thru(id: "https://doi.org/10.5284/1015681")
      expect(url).to eq("http://archaeologydataservice.ac.uk/archives/view/greylit/details.cfm?id=13979")
    end

    it "no doi" do
      url = subject.should_pass_thru(id: "http://archaeologydataservice.ac.uk/archives/view/greylit/details.cfm?id=13979")
      expect(url).to be nil
    end
  end
end
