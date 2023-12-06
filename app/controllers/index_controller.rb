class IndexController < ApplicationController
  include ActionController::MimeResponds

  before_action :load_doi, only: [:show]

  def index
    render plain: ENV['SITE_TITLE']
  end

  def show
    url = "#{ENV['API_URL']}/dois/#{@doi}"
    response = Maremma.get(url, accept: "application/vnd.datacite.datacite+json", raw: true, skip_encoding: true)

    if response.status == 200
      @metadata = Bolognese::Metadata.new(input: response.body.fetch("data", nil), from: "datacite_json")
    else
      # Non DataCite DOIs i.e. crossref are not supported.
      # Requests should go via doi.org to be redirected to the appropriate RA
      # content negotiation service
      fail AbstractController::ActionNotFound
    end

    fail AbstractController::ActionNotFound unless @metadata.exists?

    respond_to do |format|
      format.html do
        # forward to URL registered in handle system for no content negotiation
        redirect_to @metadata.url, status: 303
      end
      format.citation do
        # extract optional style and locale from header
        headers = request.headers["HTTP_ACCEPT"].to_s.gsub(/\s+/, "").split(";", 3).reduce({}) do |sum, item|
          sum[:style] = item.split("=").last if item.start_with?("style")
          sum[:locale] = item.split("=").last if item.start_with?("locale")
          sum
        end

        # fetch formatted citation
        render citation: @metadata, style: params[:style] || headers[:style] || "apa", locale: params[:locale] || headers[:locale] || "en-US"
      end
      format.any(:bibtex, :citeproc, :codemeta, :crosscite, :datacite, :datacite_json, :crossref, :jats, :ris, :schema_org, :rdf_xml, :turtle) { render request.format.to_sym => @metadata }
    end
  rescue ActionController::UnknownFormat, ActionController::RoutingError
    # forward to URL registered in handle system for unrecognized format
    redirect_to @metadata.url, status: 303
  end

  def method_not_allowed_error
    response.headers["Allow"] = "HEAD, GET, OPTIONS"
    render plain: "Method not allowed.", status: :method_not_allowed
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
