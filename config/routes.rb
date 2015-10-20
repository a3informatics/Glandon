Rails.application.routes.draw do

  root 'dashboard#index'
  
  devise_for :users
  
  resources :namespaces
  resources :registration_authorities
  resources :scoped_identifiers
  resources :thesauri
  resources :thesaurus_concepts
  resources :uploads
  resources :cdisc_bcs
  resources :forms
  resources :cdisc_terms do
    collection do
      get :compare
      get :history
    end
  end
  resources :cdisc_cls do
    collection do
      get :compare
      get :history
    end
  end
  resources :cdisc_clis do
    collection do
      get :compare
      get :history
    end
  end
  resources :iso11179_concept_systems
  namespace :iso11179_concept_systems do
    resources :iso11179_concepts
    resources :iso11179_classifications
  end
  resources :forms
  namespace :forms do
    resources :form_groups
    resources :form_items
  end
end
