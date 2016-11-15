Rails.application.routes.draw do

  root 'dashboard#index'
  
  devise_for :users
  resources :users, except: :create
  post 'create_user' => 'users#create', as: :create_user
  resources :user_settings
  
  match 'api(/:id)' => 'api#options', via: [:options]
  resources :api do
    collection do
      get :discover
      get :list
      get :form
      get :form_annotations
      get :domain
      get :thesaurus_concept
      get :bc_property
    end
  end
  resources :markdown_engines, only: [:create, :index]
  resources :dashboard do
    collection do
      get :view
      get :database
    end
  end
  resources :iso_namespaces
  resources :iso_registration_authorities
  resources :iso_concept_systems do
    collection do
      get :node_new
      post :node_add
      get :view
    end
  end
  namespace :iso_concept_systems do
    resources :nodes do
      collection do
        get :node_new
        post :node_add
      end
    end
  end
  resources :iso_scoped_identifiers
  resources :iso_registration_states do
    collection do
      get :current
    end
  end
  resources :iso_concept do
    collection do
      get :graph
    end
  end
  resources :iso_managed do
    collection do
      get :status
      get :edit_tags
      get :find_by_tag
      post :add_tag
      post :delete_tag
      get :tags
      get :graph
    end
  end
  resources :audit_trail do
    collection do
      post :search
    end
  end
  resources :thesauri do
    collection do
      get :history
      get :view
      get :search
      get :next
      post :add_child
      get :export_ttl
    end
  end
  resources :thesaurus_concepts, :only => [:update, :show, :destroy, :edit] do
    collection do
      get :impact
      post :add_child
    end
  end
  resources :uploads
  resources :notepads do
    collection do
      get :index_term
      post :create_term
      delete :destroy_term
    end
  end
  resources :cdisc_terms do
    collection do
      get :find_submission
      get :changes
      get :changesCalc
      get :changes_report
      get :compare
      get :compareCalc
      get :submission
      get :submissionCalc
      get :submission_report
      get :impact
      get :impact_calc
      get :impact_report
      get :impact_graph
      get :history
      get :search
      get :search2
      get :next
      get :import
      get :load
      get :file
      delete :file_delete
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
      post :new_template
      get :clone
      get :export_json
      get :export_ttl
      get :upgrade
    end
  end
  resources :forms do
    collection do
      get :history
      get :view
      get :placeholder_new
      post :placeholder_create
      get :acrf
      get :crf
      get :markdown
      get :crf_report
      get :acrf_report
      get :full_crf_report
      get :clone
      get :export_json
      get :export_ttl
      get :export_odm
    end
  end
  namespace :forms do
    resources :groups
    resources :items
  end
  resources :backgrounds do
    collection do
      get :running
      post :clear
      post :clear_completed
    end
  end
  resources :sdtm_models do
    collection do
      get :history
      get :import_file
      post :import
      get :export_json
      get :export_ttl
    end
  end
  namespace :sdtm_models do
    resources :variables
  end
  resources :sdtm_model_domains do
    collection do
      get :history
      get :export_json
      get :export_ttl
    end
  end
  namespace :sdtm_model_domains do
    resources :variables
  end
  resources :sdtm_igs  do
    collection do
      get :history
      get :import_file
      post :import
      get :export_json
      get :export_ttl
    end
  end
  resources :sdtm_ig_domains do
    collection do
      get :history
      get :export_json
      get :export_ttl
    end
  end
  namespace :sdtm_ig_domains do
    resources :variables
  end
  resources :sdtm_user_domains do
    collection do
      get :history
      get :add
      get :remove
      post :update_add
      post :update_remove
      get :export_json
      get :export_ttl
      get :clone
      get :full_report
    end
  end
  namespace :sdtm_user_domains do
    resources :variables
  end
end
