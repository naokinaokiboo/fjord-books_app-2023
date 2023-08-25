Rails.application.routes.draw do
  root "books#index"
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  get '/users', to: 'users#index'
  get '/users/:id', to: 'users#show', as: 'user'
  resources :books
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
