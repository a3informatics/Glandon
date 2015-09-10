Rails.application.routes.draw do

  devise_for :users
  
  resources :organizations
  resources :registration_authorities
  resources :identified_items
  resources :thesauri
  resources :thesaurus_concepts
  resources :uploads
  
end
