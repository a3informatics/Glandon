Rails.application.routes.draw do

  root 'dashboard#index'
  
  #devise_for :users
  devise_for :users, controllers: {sessions: "users/sessions"}#, :path_names => { :sign_in => "login", :sign_out => "logout" }
  resources :users, except: :create do
    member do
      put :update_name
    end
  end
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
  namespace :api do
    namespace :v2 do
      resources :thesauri, only: [:show]
      resources :thesaurus_concepts, only: [:index, :show] do
        member do
          get :parent
          get :child
        end
      end
      resources :iso_managed, only: [:index]
      resources :biomedical_concepts, only: [] do
        member do
          get :domains
        end
      end
      resources :sdtm_user_domains, only: [:show]
      resources :sdtm_ig_domains, only: [:show] do
        member do
          get :clones
        end
      end
    end
  end
  resources :markdown_engines, only: [:create, :index]
  resources :iso_namespaces, only: [:index, :new, :create, :destroy]
  resources :iso_registration_authorities, only: [:index, :new, :create, :destroy]
  resources :iso_scoped_identifiers, only: [:update]
  resources :iso_registration_states, only: [:update] do
    collection do
      get :current
    end
  end
  resources :iso_concept, only: [:show] do
    collection do
      get :graph
      get :graph_links
      get :impact
      get :impact_start
      get :impact_next
      get :changes
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
      get :graph_links
      get :impact
      get :impact_start
      get :impact_next
      get :changes
      get :comments
    end
    member do
      get :branches
      get :export
    end
  end
  resources :dashboard, only: [:index] do
    collection do
      get :view
      get :database
      get :admin
    end
  end
  resources :iso_concept_systems, only: [:index, :show] do
    member do
      post :add
    end
  end
  namespace :iso_concept_systems do
    resources :nodes, only: [:destroy, :update] do
      member do
        post :add
      end
    end
  end
  resources :audit_trail, only: [:index] do
    collection do
      post :search
      get :export_csv
    end
  end
  resources :tokens, only: [:index] do
    member do
      post :release
      get :status
      get :extend_token
    end
  end
  resources :ad_hoc_reports, only: [:index, :show, :new, :create, :destroy] do
    member do
      get :run_start
      get :run_progress
      get :run_results
      get :results
      get :export_csv
    end
  end
  
  # Thesauri
  namespace :thesauri do
    resources :managed_concepts, only: [:show, :edit, :update, :destroy] do
      member do
        get :children
        post :add_child
        get :changes
        get :differences
        get :synonym_links
        get :preferred_term_links
        get :change_instruction_links
        post :extensions, action: :add_extensions
        delete :extensions, action: :destroy_extensions
        get :is_extended
        get :is_extension
      end
    end
    resources :unmanaged_concepts, only: [:show, :edit, :update, :destroy] do
      member do
        get :show_data
        get :changes
        get :changes_data
        get :differences
        get :synonym_links
        get :preferred_term_links
        get :change_instruction_links
      end
    end
  end

  resources :thesauri, only: [:index, :show, :create, :edit, :destroy] do
    collection do
      get :history
      post :extension
      get :search_current
    end
    member do
      get :children
      post :add_child
      get :changes
      get :changes_report
      get :submission
      get :submission_report
      get :search
      get :export_csv
    end
  end

  # resources :thesaurus_concepts, :only => [:update, :show, :destroy, :edit] do
  #   collection do
  #     get :children
  #     post :add_child
  #   end
  #   member do
  #     get :cross_reference_start
  #     get :cross_reference_details
  #   end
  # end
  
  resources :uploads

  # Imports
  namespace :imports do
    resources :adam_models, :only => [:new, :create]
    resources :adam_igs, :only => [:new, :create]
    resources :cdisc_terms, :only => [:new, :create]
    resources :change_instructions, :only => [:new, :create]
    resources :crfs, :only => [:new, :create] do
      collection do
        get :items
      end
    end
    resources :terms, :only => [:new, :create] do
      collection do
        get :items
      end
    end
  end
  resources :imports, :only => [:index, :show, :destroy] do # Make sure this is after the namespace to avoid the :index/:show clash
    collection do
      get :list
      delete :destroy_multiple
    end
  end 
  
  # Exports
  resources :exports, :only => [:index] do
    collection do
      get :terminologies
      get :biomedical_concepts
      get :forms
      get :start
      get :download
    end
  end

  # CDISC Terminology
  resources :cdisc_terms, :only => [:index] do
    collection do
      get :history
    end
    member do
      get :changes
    end
  end

  # BCs
  resources :biomedical_concept_templates do
    collection do
      get :history
      get :list
      get :all
    end
  end
  namespace :biomedical_concepts do
    resources :items
    resources :datatypes
    resources :properties do
      member do
        post 'term', to: 'properties#add', as: :add
        delete 'term', to: 'properties#remove', as: :remove
      end
    end
    resources :property_values
  end
  resources :biomedical_concepts do
    member do
      get :export_json
      get :export_ttl
      get :clone
      get :upgrade
      get :show_full
      get :edit_lock
    end
    collection do
      get :editable
      get :history
      post :clone_create
      get :list
      get :edit_multiple
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
      get :clone
      post :clone_create
      get :branch
      post :branch_create
      get :export_json
      get :export_ttl
      get :export_odm
    end
  end
  namespace :forms do
    resources :groups
    resources :items, :only => [:show]
  end
  resources :backgrounds, :only => [:index, :destroy] do
    collection do
      delete :destroy_multiple
    end
  end
  resources :sdtm_models do
    collection do
      get :history
      get :import
      post :create
    end
    member do
      get :export_json
      get :export_ttl
    end
  end
  namespace :sdtm_models do
    resources :variables
  end
  resources :sdtm_model_domains, :only => [:show] do
    collection do
      #get :history
    end
    member do
      get :export_json
      get :export_ttl
    end
  end
  resources :sdtm_igs do
    collection do
      get :history
      get :import
      post :create
    end
    member do
      get :export_json
      get :export_ttl
    end
  end
  resources :sdtm_ig_domains, :only => [:show] do
    member do
      get :export_json
      get :export_ttl
    end
  end
  resources :sdtm_user_domains do
    member do
      get :export_json
      get :export_ttl
      get :full_report
      get :export_xpt_metadata
    end
    collection do
      get :history
      get :clone_ig
      post :clone_ig_create
      get :list
      get :add
      get :remove
      post :update_add
      post :update_remove
      get :sub_classifications
    end
  end
  resources :adam_igs do
    collection do
      get :history
    end
    member do
      get :export_json
      get :export_ttl
    end
  end
    resources :adam_ig_datasets, :only => [:show] do
    member do
      get :export_json
      get :export_ttl
    end
  end

end