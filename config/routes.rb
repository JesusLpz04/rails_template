Rails.application.routes.draw do
  namespace :admin do
    # This creates the paths for ban and unban actions in the users controller
    resources :users, only: [:index] do
      patch :ban, on: :member   # Path for banning a user
      patch :unban, on: :member # Path for unbanning a user
    end

    get 'dashboard', to: 'dashboard#index', as: 'dashboard'
    resources :reports, only: [:index, :destroy]
    resources :claims, only: [:index, :show, :update]

    resources :claims, only: [] do
      member do
        patch :approve
        patch :reject
      end
    end
  end

  get "map/index"
  get 'latest', to: 'posts#latest'
  get "up" => "rails/health#show", as: :rails_health_check
  get "/map", to: "map#index"
  get '/guest_login', to: 'sessions#guest'

  # Devise login override & manual logout
  devise_for :users, skip: [:sessions]
  as :user do
    get "/users/sign_in", to: redirect("/email_login")
    delete "/logout", to: "devise/sessions#destroy", as: :logout
  end

  # UTRGV Email Login Routes
  get  "/email_login",  to: "email_codes#new"
  post "/email_login",  to: "email_codes#create"
  get  "/verify_code",  to: "email_codes#verify"
  post "/verify_code",  to: "email_codes#verify"

  resources :email_codes, only: [:new, :create]

  authenticated :user do
    root to: "home#index", as: :authenticated_root
  end

  unauthenticated do
    root to: "email_codes#new", as: :unauthenticated_root
  end

  # Main app resources
  resources :lost_items
  resources :posts
  resources :found_items
  resources :claims, only: [:new, :create, :destroy]
  resources :users, only: [:show, :edit, :update, :destroy]
  resources :reports, only: [:index, :create, :destroy]
  resources :notifications, only: [:index, :destroy]

  # Route for banned page
  get 'errors/banned', to: 'errors#banned', as: :banned
end