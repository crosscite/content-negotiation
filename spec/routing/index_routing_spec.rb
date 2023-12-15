require 'rails_helper'

RSpec.describe 'Index routing', type: :routing do
  it 'routes GET / to index#show' do
    expect(get: '/').to route_to(controller: 'index', action: 'index')
  end

  it 'routes GET /index to index#index' do
    expect(get: '/index').to route_to(controller: 'index', action: 'show', id: 'index')
  end

end