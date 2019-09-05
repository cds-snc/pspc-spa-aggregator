Rails.application.routes.draw do
  namespace 'api' do
    namespace 'v1' do
      get '/procurements/search', to: 'procurements#search', as: :search
      resources :procurements, only: [:index, :show]
    end
  end

  get '/procurements/search', to: 'procurements#index'
  post '/procurements/search', to: 'procurements#search', as: 'search'
  resources :procurements, only: [:index, :show], constraints: { format: :html }

  root to: 'procurements#index'
end
