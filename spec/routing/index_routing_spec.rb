require 'rails_helper'

RSpec.describe 'Index routing', type: :routing do
  it 'routes GET / to index#index' do
    expect(get: '/').to route_to(controller: 'index', action: 'index')
  end

  it 'routes GET /index to index#show' do
    expect(get: '/index').to route_to(controller: 'index', action: 'show', id: 'index')
  end

  it 'does not route GET /index.xml to index#show' do
    expect(get: '/index.xml').not_to route_to(controller: 'index', action: 'show', id: 'index', format: 'xml')
  end

  it 'routes GET /custom_id to index#show with custom_id' do
    expect(get: '/custom_id').to route_to(controller: 'index', action: 'show', id: 'custom_id')
  end

  it 'does not route GET /custom_id.xml to index#show with custom_id and xml format' do
    expect(get: '/custom_id.xml').not_to route_to(controller: 'index', action: 'show', id: 'custom_id', format: 'xml')
  end

  it 'routes GET / with format: false to index#index' do
    expect(get: '/', constraints: { format: false }).to route_to(controller: 'index', action: 'index')
  end

  it 'does not route GET /index.xml with format: false to index#show' do
    expect(get: '/index.xml', constraints: { format: false }).not_to route_to(controller: 'index', action: 'show', id: 'index', format: 'xml')
  end

  it 'does not route GET /custom_id.xml with format: false to index#show with custom_id' do
    expect(get: '/custom_id.xml', constraints: { format: false }).not_to route_to(controller: 'index', action: 'show', id: 'custom_id', format: 'xml')
  end
end
