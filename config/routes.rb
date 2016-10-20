Rails.application.routes.draw do

  root to: 'articles#index'
  resources :articles, only: [ :index ]
  resources :properties, only: [ :index ]
end
