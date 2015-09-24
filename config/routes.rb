Rails.application.routes.draw do

  root 'dashboard#index'
  
  devise_for :users
  
  resources :organizations
  resources :registration_authorities
  resources :identified_items
  resources :thesauri
  resources :thesaurus_concepts
  resources :uploads
  resources :cdisc_terms
  resources :cdisc_cls
  resources :cdisc_clis
  
end
