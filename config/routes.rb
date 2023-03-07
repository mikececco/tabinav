Rails.application.routes.draw do
  devise_for :users
  root to: "pages#home"
  resources :routes, only: %i[index show create] do
    resources :bookmarks, only: [:create]
  end

  resources :bookmarks, only: %i[index edit update destroy]

  # resources :bookmarks
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Defines the root path route ("/")
  # root "articles#index"
end
