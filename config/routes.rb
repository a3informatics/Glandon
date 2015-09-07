Rails.application.routes.draw do
  
  #get 'registration_authority/new'

  #get 'registration_authority/create'

  #get 'registration_authority/update'

  #get 'registration_authority/edit'

  #get 'registration_authority/destroy'

  #get 'registration_authority/index'

  #get 'registration_authority/show'

  get 'identified_item/new'

  get 'identified_item/create'

  get 'identified_item/update'

  get 'identified_item/edit'

  get 'identified_item/destroy'

  get 'identified_item/index'

  get 'identified_item/show'

  root to: 'dashboard#index'
  
  devise_for :users
  
  resources :organizations
  resources :registration_authorities
  
end
