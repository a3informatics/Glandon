Rails.application.routes.draw do

  root 'dashboard#index'
  
  devise_for :users
  
  resources :dashboard do
    collection do
      get :view
    end
  end
  resources :iso_namespaces
  resources :scoped_identifiers
  resources :registration_authorities
  resources :registration_states
  resources :managed_items
  resources :thesauri
  resources :thesaurus_concepts do
    collection do
      get :showD3
    end
  end
  resources :uploads
  resources :biomedical_concept_templates
  resources :cdisc_bcs do
    collection do
      get :bct_select
    end
  end
  resources :cdisc_terms do
    collection do
      get :compare
      get :history
      get :search
    end
  end
  resources :sponsor_terms do
    collection do
      get :search
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
  resources :iso_concept_systems do
    collection do
      get :node_new
      post :node_add
    end
  end
  namespace :iso_concept_systems do
    resources :nodes
    resources :classifications
  end
  resources :forms do
    collection do
      get :view
      get :placeholder_new
      get :bc_normal_new
      get :bc_log_new
      post :placeholder_create
      post :bc_normal_create
      post :bc_log_create
      get :acrf
    end
  end
  namespace :forms do
    resources :form_groups
    resources :form_items
  end
  resources :domains do
    collection do
      get :add
      get :remove
      post :update_add
      post :update_remove
    end
  end
  namespace :domains do
    resources :variables
  end
  resources :standards
  resources :sdtmigs
end
