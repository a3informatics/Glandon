Rails.application.routes.draw do

  root 'dashboard#index'
  
  devise_for :users
  
  match 'api(/:id)' => 'api#options', via: [:options]
  resources :api do
    collection do
      get :form
    end
  end
  
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
  resources :biomedical_concept_templates do
    collection do
      get :history
    end
  end
  namespace :biomedical_concepts do
    resources :items
    resources :datatypes
    resources :properties
    resources :property_values
  end
  resources :biomedical_concepts do
    collection do
      get :list
      get :history
      get :impact
    end
  end
  resources :cdisc_terms do
    collection do
      get :changesCalc
      get :changes
      get :compareCalc
      get :compare
      get :submissionCalc
      get :submission
      get :history
      get :searchOld
      get :search
      get :search2
      get :next
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
      get :history
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
    resources :groups
    resources :items
  end
  resources :domains do
    collection do
      get :history
      get :add
      get :remove
      post :update_add
      post :update_remove
    end
  end
  namespace :domains do
    resources :variables
  end
  resources :backgrounds do
    collection do
      get :running
      post :clear
    end
  end
  resources :standards
  resources :sdtmigs
end
