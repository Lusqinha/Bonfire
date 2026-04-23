Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :registration, only: %i[new create]

  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"

  # English routes
  get "library", to: "library#index", as: :library
  resources :books do
    resources :reading_entries, shallow: true
    resources :notes, shallow: true
  end
  get "search/books", to: "search#books"

  # PT-BR route aliases
  get "biblioteca",       to: "library#index"
  get "entrar",           to: "sessions#new"
  get "criar-conta",      to: "registrations#new"

  scope path: "/livros" do
    get "/",              to: "library#index"
    get "/:id",           to: "books#show",    constraints: { id: /\d+/ }
  end
end
