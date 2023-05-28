Rails.application.routes.draw do
  root "google_maps#maps"

  get '/locations', to: 'google_maps#saved_locations', as: 'places'
  get '/add_location', to: 'google_maps#add_location', as: 'new_place'

  resources :distances, only: [:new, :create]
end
