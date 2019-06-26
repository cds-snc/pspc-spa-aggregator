Rails.application.routes.draw do
  namespace 'api' do
    namespace 'v1' do
      get '/procurements/search', to: 'procurements#search', as: :search
      resources :procurements, only: [:index, :show]
    end
  end
end
