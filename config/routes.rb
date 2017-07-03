Rails.application.routes.draw do

  root 'dashboard#index'
  
  #devise_for :users
  devise_for :users, controllers: {sessions: "users/sessions"}#, :path_names => { :sign_in => "login", :sign_out => "logout" }
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
  resources :iso_namespaces
  resources :iso_registration_authorities
  resources :iso_scoped_identifiers
  resources :iso_registration_states, only: [:index, :update] do
    collection do
      get :current
    end
  end
  resources :iso_concept, only: [:show] do
    collection do
      get :graph
      get :graph_links
      get :impact
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
    end
    member do
      get :branches
    end
  end
  resources :dashboard, only: [:index] do
    collection do
      get :view
      get :database
    end
  end
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
  resources :thesauri do
    collection do
      get :history
      get :view
      get :search
      get :search_results
      get :search_current
      #get :next
      get :children
      post :add_child
      get :export_ttl
    end
  end
  resources :thesaurus_concepts, :only => [:update, :show, :destroy, :edit] do
    collection do
      get :children
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
      get :changes_calc
      get :changes_report
      get :compare
      get :compare_calc
      get :submission
      get :submission_calc
      get :submission_report
      get :impact
      get :impact_calc
      get :impact_report
      get :impact_graph
      get :history
      get :search
      get :search_results
      #get :next
      get :import
      get :load
      get :file
      delete :file_delete
    end
  end
  resources :cdisc_cls, :only => [:show] do
    collection do
      get :changes
    end
  end
  resources :cdisc_clis, :only => [:show] do
    collection do
      get :changes
    end
  end
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
  #namespace :sdtm_model_domains do
  #  resources :variables
  #end
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
    collection do
      #get :history
    end
    member do
      get :export_json
      get :export_ttl
    end
  end
  #namespace :sdtm_ig_domains do
  #  resources :variables
  #end
  resources :sdtm_user_domains do
    member do
      get :export_json
      get :export_ttl
      get :full_report
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
  #namespace :sdtm_user_domains do
  #  resources :variables
  #end
end
