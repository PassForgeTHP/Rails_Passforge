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
    resource :master_password, only: [:show, :create, :update]

    # Two-factor authentication routes
    namespace :auth do
      namespace :two_factor do
        post 'setup', to: 'two_factor_auth#setup'
        post 'verify', to: 'two_factor_auth#verify'
        delete 'disable', to: 'two_factor_auth#disable'
        post 'verify_login', to: 'two_factor_auth#verify_login'
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
