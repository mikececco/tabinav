Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  mount StripeEvent::Engine, at: '/stripe-webhooks'

  resources :routes, only: %i[index show create] do
    resources :bookmarks, only: [:create]
    resources :days, only: [:create]
  end

  #For Stripe Payments
  resources :orders, only: [:show, :create] do
    resources :payments, only: :new
  end

  resources :bookmarks, only: %i[index edit update destroy] do
    resources :bookings, only: [:new, :create]
  end

  resources :bookings, only: %i[index show edit update destroy]
  resources :days, only: %i[index update destroy]

  # resources :bookmarks
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Defines the root path route ("/")
  # root "articles#index"
end
