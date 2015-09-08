Rails.application.routes.draw do

  root to: 'dashboard#index'
  
  devise_for :users
  
  resources :organizations
  resources :registration_authorities
  resources :identified_items
  resources :thesauri
  resources :thesaurus_concepts
  
end
