class IndexController < ApplicationController
  include ActionController::MimeResponds

  before_action :load_doi, only: [:show]

  def index
    render plain: ENV['SITE_TITLE']
  end

  def show
    ra = get_doi_ra(@doi)
    if ra == "DataCite"
      url = Rails.env.production? ? "https://api.datacite.org/dois/#{@doi}" : "https://api.test.datacite.org/dois/#{@doi}"
      response = Maremma.get(url, accept: "application/vnd.datacite.datacite+json", raw: true)
      fail AbstractController::ActionNotFound if response.status != 200

      @metadata = Bolognese::Metadata.new(input: response.body.fetch("data", nil), from: "datacite_json")
    elsif ra == "Crossref"
      url = "https://api.crossref.org/works/#{@doi}/transform/application/vnd.crossref.unixsd+xml"
      response = Maremma.get(url, accept: "text/xml", raw: true)
      fail AbstractController::ActionNotFound if response.status != 200
      
      string = response.body.fetch("data", nil)
      string = Nokogiri::XML(string, nil, 'UTF-8', &:noblanks).to_s if string.present?
      @metadata = Bolognese::Metadata.new(input: string, from: "crossref")
    elsif %w(mEDRA JaLC).include?(ra)
      # we fetch the Citeproc JSON from DOI content negotiation for the other RAs that support this
      url = "https://doi.org/#{@doi}"
      response = Maremma.get(url, accept: "application/vnd.citationstyles.csl+json", raw: true)
      fail AbstractController::ActionNotFound if response.status != 200
      
      string = response.body.fetch("data", nil)
      @metadata = Bolognese::Metadata.new(input: string, from: "citeproc")
    else
      fail AbstractController::ActionNotFound
    end

    fail AbstractController::ActionNotFound unless @metadata.exists?

    respond_to do |format|
      format.html do
        # forward to URL registered in handle system for no content negotiation
        redirect_to @metadata.url, status: 303
      end
      format.citation do
        # fetch formatted citation
        render citation: @metadata, style: params[:style] || "apa", locale: params[:locale] || "en-US"
      end
      format.any(:bibtex, :citeproc, :codemeta, :crosscite, :datacite, :datacite_json, :crossref, :jats, :ris, :schema_org, :rdf_xml, :turtle) { render request.format.to_sym => @metadata }
    end
  rescue ActionController::UnknownFormat, ActionController::RoutingError
    # forward to URL registered in handle system for unrecognized format
    redirect_to @metadata.url, status: 303
  end

  def routing_error
    fail AbstractController::ActionNotFound
  end

  protected

  def load_doi
    @doi = validate_doi(params[:id])
    fail AbstractController::ActionNotFound unless @doi.present?
  end
end
