Rails.application.routes.draw do
  devise_for :users,
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations'
             }
  get '/member-data', to: 'members#show'
  get "up" => "rails/health#show", as: :rails_health_check

  # API namespace
  namespace :api, defaults: { format: :json } do
    resources :passwords, only: [:index, :show, :create, :update, :destroy]
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
