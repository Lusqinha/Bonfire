Rails.application.routes.draw do
  # Auth
  resource :session, path: "sessao"
  resources :passwords, param: :token
  resource :registration, path: "conta", only: %i[new create]

  get "up" => "rails/health#show", as: :rails_health_check

  # Pages
  root "home#index"
  get "biblioteca", to: "library#index", as: :library

  # Books and nested resources — PT-BR paths
  resources :books, path: "livros" do
    resources :reading_entries, path: "registros", shallow: true
    resources :notes, path: "notas", shallow: true
  end

  get "buscar/livros", to: "search#books"

  # English aliases → redirect to PT-BR
  get "library",           to: redirect("/biblioteca")
  get "session/new",       to: redirect("/sessao/nova")
  get "registration/new",  to: redirect("/conta/nova")
  get "books/:id",         to: redirect("/livros/%{id}"), constraints: { id: /\d+/ }
end
