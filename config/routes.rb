Rails.application.routes.draw do

  root 'dashboard#index'
  
  devise_for :users
  
  match 'api(/:id)' => 'api#options', via: [:options]
  resources :api
  
  resources :dashboard do
    collection do
      get :view
      get :database
    end
  end
  resources :iso_namespaces
  resources :iso_scoped_identifiers
  resources :iso_registration_authorities
  resources :iso_registration_states
  resources :thesauri do
    collection do
      get :history
      get :view
      get :search
      get :searchNew
      get :searchOld
    end
  end
  resources :thesaurus_concepts do
    collection do
      get :impact
      get :showD3
    end
  end
  resources :uploads
  resources :biomedical_concept_templates
  resources :cdisc_bcs do
    collection do
      get :bct_select
      get :impact
    end
  end
  resources :cdisc_terms do
    collection do
      get :changes
      get :compare
      get :history
      get :import
      get :search
      get :searchNew
      get :searchOld
      get :import
    end
  end
  resources :cdisc_cls do
    collection do
      get :compare
      get :history
      get :changes
    end
  end
  resources :cdisc_clis do
    collection do
      get :compare
      get :history
      get :impact
      get :changes
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
      get :crf
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
