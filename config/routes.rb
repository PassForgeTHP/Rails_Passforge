Rails.application.routes.draw do
  devise_for :users,
             controllers: {
               sessions: 'users/sessions',
               registrations: 'users/registrations'
             }
  get '/member-data', to: 'members#show'
  devise_scope :user do
    delete '/users', to: 'users/registrations#destroy'
  end
  get "up" => "rails/health#show", as: :rails_health_check

 resources :contacts, only: [:create], defaults: { format: :json }
  # API namespace
  namespace :api, defaults: { format: :json } do
    resources :passwords, only: [:index, :show, :create, :update, :destroy]
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
