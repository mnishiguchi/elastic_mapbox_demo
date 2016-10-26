Rails.application.routes.draw do

  get "properties/autocomplete" => "properties#autocomplete"

  resources :managements, only: [ :index, :show ]
  resources :properties, only: [ :index, :show ]
  resources :floorplans, only: [ :index, :show ]

  root to: 'properties#index'
end
