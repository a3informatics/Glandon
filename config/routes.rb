Rails.application.routes.draw do

  root 'dashboard#index'

  #devise_for :users
  devise_for :users, controllers: {sessions: "users/sessions"}#, :path_names => { :sign_in => "login", :sign_out => "logout" }
  resources :users, except: :create do
    member do
      put :update_name
      put :lock
      put :unlock
    end
    collection do
     get :stats_by_domain
    #   get :stats_by_year
    #   get :stats_by_current_week
    #   get :stats_by_year_by_month
    #   get :stats_by_year_by_week
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
  resources :iso_scoped_identifiers_v2, only: [:update]
  resources :iso_registration_states, only: [:update] do
    collection do
      get :current
    end
  end
  resources :iso_concept, only: [:show] do
    #collection do
      # get :graph
      # get :graph_links
      # get :impact
      # get :impact_start
      # get :impact_next
      # get :changes
    #end
    member do
      get :tags
      put :add_tag
      put :remove_tag
      get :edit_tags
      get :tags_full
      get :change_notes
      get :change_instructions
      get :indicators
      post :change_note, action: :add_change_note
    end
  end
  namespace :annotations do
    resources :change_notes, only: [:update, :destroy]
    resources :change_instructions, only: [:create, :edit, :update, :destroy] do
      member do
        get :show
        put :add_references
        put :remove_reference
      end
    end
  end
  resources :iso_managed_v2, only: [:edit, :update] do
    collection do
      get :find_by_tag
      get :comments
    end
    member do
      get :status
      get :impact
      get :make_current
      post :next_state
      put :set_semantic_version
      put :set_version_label
      get :list_change_notes
      get :list_change_notes_data
      get :custom_properties
      get :export_change_notes_csv
      get :export_ttl
      get :export_json
    end
  end
  resources :iso_registration_states_v2, only: [] do
    member do
      put :update
    end
  end
  resources :dashboard, only: [:index] do
    collection do
      # get :view
      # get :database
      # get :admin
    end
  end
  resources :iso_concept_systems, only: [:index, :show, :destroy] do
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
      get :stats_by_domain
      get :stats_by_year
      get :stats_by_current_week
      get :stats_by_year_by_month
      get :stats_by_year_by_week
    end
  end
  resources :tokens, only: [:index] do
    member do
      post :release
      get :status
      get :extend_token
    end
    collection do
      post :release_multiple
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
    resources :managed_concepts, only: [:index, :show, :edit, :update, :create, :destroy] do
      collection do
        get :history
        get :set_with_indicators
      end
      member do
        get :edit_extension
        get :edit_subset
        get :find_subsets
        get :children
        post :add_child
        post :add_children
        post :add_children_synonyms
        post :create_extension
        post :create_subset
        get :show_data
        get :changes
        get :changes_data
        get :changes_report
        get :differences
        get :synonym_links
        get :preferred_term_links
        get :change_instruction_links
        post :extensions, action: :add_extensions
        # delete :extensions, action: :destroy_extensions
        get :is_extended
        get :is_extension
        get :export_csv
        get :changes_summary
        get :changes_summary_data
        get :changes_summary_data_impact
        get :impact
        get :differences_summary
        patch :update_properties
        get :upgrade_data
        put :upgrade
        post :add_rank
        delete :remove_rank
        put :update_rank
        get :children_ranked
        post :pair
        post :unpair
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
        patch :update_properties
      end
    end
    resources :subsets, only: [] do
      member do
        post :add
        delete :remove
        delete :remove_all
        put :move_after
        get :list_children
      end
    end
  end

  resources :thesauri, only: [:index, :show, :create, :edit, :destroy] do
    collection do
      get :index_owned
      get :history
      post :extension
      get :search_current
      get :search_multiple
    end
    member do
      post :clone
      get :children
      get :children_with_indicators
      post :add_child
      get :changes
      get :changes_data
      get :changes_report
      get :changes_impact
      get :export_csv
      get :submission
      get :submission_data
      get :submission_report
      get :search
      get :export_csv
      post :add_subset
      get :release_select
      put :reference, action: :set_reference
      get :reference, action: :get_reference
      post :select_children
      put :deselect_children
      put :deselect_all_children
      put :change_child_version
      get :compare
      get :compare_data
      get :compare_csv
      get :upgrade
      get :impact
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

  resources :uploads, :only => [:index, :create] do
    collection do
      delete :destroy_multiple
      delete :destroy_all
    end
  end

  # Imports
  namespace :imports do
    # resources :adam_models, :only => [:new, :create]
    # resources :adam_igs, :only => [:new, :create]
    resources :cdisc_terms, :only => [:new, :create]
    resources :change_instructions, :only => [:new, :create]
    resources :crfs, :only => [:new, :create] do
      collection do
        get :items
      end
    end
    resources :sponsor_term_format_two, :only => [:new, :create]
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
    end
  end

  # BCs
  resources :biomedical_concept_templates do
    collection do
      get :history
    end
  end
  resources :biomedical_concept_instances do
    member do
      get :show_data
      get :edit_data
      get :edit_another
      put :update_property
    end
    collection do
      get :history
      post :create_from_template
    end
  end

  #Forms
  resources :forms do
    member do
      get :show_data
      get :crf
      get :acrf
      get :referenced_items
      post :add_child
    end
    collection do
      get :history
      # get :view
      # get :placeholder_new
      # post :placeholder_create
      # get :acrf
      # get :crf
      # get :markdown
      # get :clone
      # post :clone_create
      # get :branch
      # post :branch_create
      # get :export_json
      # get :export_ttl
      # get :export_odm
    end
  end
  namespace :forms do
    namespace :items do
      resources :questions, :text_labels, :placeholders, :mappings, :commons, :bc_properties, :only => [:update, :destroy] do
        member do
          put :move_up
          put :move_down
          post :add_child
        end
      end
      resources :bc_properties do
        member do
          post :make_common
        end
      end
      resources :commons do
        member do
          delete :restore
        end
      end
    end
    namespace :groups do
      resources :bc_groups, :normal_groups, :common_groups, :only => [:update, :destroy] do
        member do
          put :move_up
          put :move_down
          post :add_child
        end
      end
    end
  end

  namespace :operational_reference_v3 do
    resources :tuc_references, :only => [:update, :destroy] do
      member do
          put :move_up
          put :move_down
      end
    end
  end

  resources :backgrounds, :only => [:index, :destroy] do
    collection do
      delete :destroy_multiple
    end
  end

  #SDTM
  resources :sdtm_models, :only => [:show, :index] do
    collection do
      get :history
      # get :import
      # post :create
    end
    member do
      get :show_data
      # get :export_json
      # get :export_ttl
    end
  end
  namespace :sdtm_models do
    resources :variables
  end
  resources :sdtm_classes, :only => [:show, :index] do
    collection do
      get :history
    end
    member do
      get :show_data
    end
  end
  resources :sdtm_igs, :only => [:show, :index] do
    collection do
      get :history
      # get :import
      # post :create
    end
    member do
      get :show_data
      # get :export_json
      # get :export_ttl
    end
  end
  resources :sdtm_ig_domains, :only => [:show, :index] do
    collection do
      get :history
      # get :import
      # post :create
    end
    member do
      get :show_data
      # get :export_json
      # get :export_ttl
    end
  end
  resources :sdtm_sponsor_domains, :only => [:show, :index, :edit, :update, :destroy] do
    collection do
      get :history
      post :create_from
#      post :create_from_ig
#      post :create_from_class
      get :editor_metadata
    end
    member do
      get :show_data
      post :add_non_standard_variable
      delete :delete_non_standard_variable
      put :update_variable
      get :bc_associations
      post :add_bcs
      put :remove_bcs
      put :remove_all_bcs
    end
  end

  #ADAM
  resources :adam_igs, :only => [:show, :index] do
    collection do
      get :history
    end
    member do
      get :show_data
      # get :export_json
      # get :export_ttl
    end
  end
  resources :adam_ig_datasets, :only => [:show, :index] do
    collection do
      get :history
    end
    member do
      get :show_data
      # get :export_json
      # get :export_ttl
    end
  end

end
