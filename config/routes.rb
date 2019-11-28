Rails.application.routes.draw do
  resources :heartbeat, only: [:index]
  
  # content negotiation via url
  get '/application/vnd.datacite.datacite+xml/:id', :to => 'index#show', constraints: { :id => /.+/ }, defaults: { format: :datacite }
  get '/application/vnd.datacite.datacite+json/:id', :to => 'index#show', constraints: { :id => /.+/ }, defaults: { format: :datacite_json }
  get '/application/vnd.crosscite.crosscite+json/:id', :to => 'index#show', constraints: { :id => /.+/ }, defaults: { format: :crosscite }
  get '/application/vnd.schemaorg.ld+json/:id', :to => 'index#show', constraints: { :id => /.+/ }, defaults: { format: :schema_org }
  get '/application/vnd.codemeta.ld+json/:id', :to => 'index#show', constraints: { :id => /.+/ }, defaults: { format: :codemeta }
  get '/application/vnd.citationstyles.csl+json/:id', :to => 'index#show', constraints: { :id => /.+/ }, defaults: { format: :citeproc }
  get '/application/vnd.jats+xml/:id', :to => 'index#show', constraints: { :id => /.+/ }, defaults: { format: :jats }
  get '/application/x-bibtex/:id', :to => 'index#show', constraints: { :id => /.+/ }, defaults: { format: :bibtex }
  get '/application/x-research-info-systems/:id', :to => 'index#show', constraints: { :id => /.+/ }, defaults: { format: :ris }
  get '/application/vnd.crossref.unixref+xml/:id', :to => 'index#show', constraints: { :id => /.+/ }, defaults: { format: :crossref }
  get '/application/rdf+xml/:id', :to => 'index#show', constraints: { :id => /.+/ }, defaults: { format: :rdf_xml }
  get '/application/x-turtle/:id', :to => 'index#show', constraints: { :id => /.+/ }, defaults: { format: :turtle }
  get '/text/x-bibliography/:id', :to => 'index#show', constraints: { :id => /.+/ }, defaults: { format: :citation }
  
  resources :index, path: '/', only: [:show, :index], constraints: { id: /.+/, format: false }
  root :to => 'index#index'

  # rescue method not allowed errors
  match "*path", to: "index#method_not_allowed_error", via: [:post, :put, :patch, :delete]

  # rescue routing errors
  match "*path", to: "index#routing_error", via: :all
end
