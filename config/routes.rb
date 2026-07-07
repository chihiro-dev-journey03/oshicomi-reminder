Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  root "static_pages#top"
  get "register", to: "static_pages#register", as: :register
  get "login",    to: "static_pages#login",    as: :login

  resources :reminders, only: [ :index, :new, :create, :edit, :update, :destroy ]
  resources :recommend_lists, only: [ :index, :new, :create, :show, :edit, :update, :destroy ] do
    collection do
      get :my_lists
    end
  end

  resources :books, only: [] do
    collection do
      get :search
    end
  end

  resource :profile, only: [ :show, :edit, :update ], module: :users

  namespace :internal do
    post "reminders/send_due", to: "reminders#send_due"
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
