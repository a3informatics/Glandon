Rails.application.routes.draw do
  
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
  
end
