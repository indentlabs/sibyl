Rails.application.routes.draw do
  resources :images

  root to: 'search#index'
  get 'search/results'
end
