Rails.application.routes.draw do
  resources :heartbeat, only: [:index]

  # workaround for fetching accept header in path
  get '/application/*application_accept/:id', to: 'index#show', constraints: { id: /.+/, format: false }
  get '/text/*text_accept/:id', to: 'index#show', constraints: { id: /.+/, format: false }
  resources :index, path: '/', only: [:show, :index], constraints: { id: /.+/, format: false }

  root :to => 'index#index'

  # rescue routing errors
  match "*path", to: "index#routing_error", via: :all
end
