Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  resources :routes, only: %i[index show create] do
    resources :bookmarks, only: [:create]
    resources :days, only: [:create]
  end

  resources :bookmarks, only: %i[index edit update destroy] do
    resources :bookings, only: [:new, :create]
  end

  resources :bookings, only: %i[index show edit update destroy]
  resources :days, only: %i[index update destroy] do
    patch "upgrade_hotel", to: "days#upgrade_hotel"
    patch "downgrade_hotel", to: "days#downgrade_hotel"
    patch "change_activity", to: "days#change_activity"
  end

  patch "update_sequence", to: "days#update_sequence"

  # resources :bookmarks
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Defines the root path route ("/")
  # root "articles#index"
end
