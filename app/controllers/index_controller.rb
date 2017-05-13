class IndexController < ApplicationController
  before_action :load_id, :set_content_type, only: [:show]

  def index
    render plain: ENV['SITE_TITLE']
  end

  # instead of letting Rails handle this, we determine content-type for the response, in that order:
  # 1. content-type registered for specific DOI
  # 2. formatted citation via DOI formatter service
  # 3. content-type registered for all DOIs
  # 4. no content-type found, pass through to URL registered in handle system
  # then redirect (1, 4) or render (2, 3) based on content_type
  def show
    # content-type registered for specific DOI
    if @media_url.present?
      response.set_header("Accept", @content_type)
      Rails.logger.info "#{@id} redirected as #{@content_type}"
      redirect_to @media_url, status: 303 and return
    end

    # formatted citation via DOI formatter service
    if @content_type.to_s.starts_with?("text/x-bibliography")
      response.set_header("Accept", @content_type)
      Rails.logger.info "#{@id} returned as #{@content_type}"
      render plain: formatted_citation(id: @id, content_type: @content_type),
        content_type: @content_type and return
    end

    # content-type available in content negotiation
    if available_content_types.keys.include?(@content_type)
      @metadata = Metadata.new(input: @id)
      fail AbstractController::ActionNotFound unless @metadata.valid?

      format = Mime::Type.lookup(@content_type).to_sym
      response.set_header("Accept", @content_type)
      Rails.logger.info "#{@id} returned as #{@content_type}"
      render format => @metadata and return
    end

    # no content-type found, passed on to URL registered in handle system
    handle_url = get_handle_url(id: @id)
    accept_headers = @accept_headers.join(', ').presence || "*/*"
    response.set_header("Accept", accept_headers)
    Rails.logger.info "#{@id} passed on as #{accept_headers}"
    redirect_to handle_url, status: 303
  end

  def routing_error
    fail AbstractController::ActionNotFound
  end

  protected

  # id can be DOI or DOI expressed as URL
  def load_id
    @id = normalize_id(params[:id])
    fail AbstractController::ActionNotFound unless @id.present?
  end

  def set_content_type
    # if accept_headers are provided via link URL
    if params[:application_accept].present?
      @accept_headers = ["application/" + params[:application_accept]]
    elsif params[:text_accept].present?
      @accept_headers = ["text/" + params[:text_accept].gsub('+', '')]
    else
      # get all accept headers provided by client
      @accept_headers = request.accepts.map { |i| i.to_s }
    end

    # get all registered content_types
    registered_content_types = get_registered_content_types(@id)

    # select first match as content_type, handle text/x-bibliography differently
    if @accept_headers.first.to_s.starts_with?("text/x-bibliography")
      @content_type = @accept_headers.first
    else
      content_types = registered_content_types.keys + available_content_types.keys
      @content_type = (@accept_headers & content_types).first
    end

    # redirect url if content_type is from registered content
    @media_url = registered_content_types[@content_type]
  end
end
