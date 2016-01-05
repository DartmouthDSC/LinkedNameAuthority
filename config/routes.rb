Rails.application.routes.draw do
  root to: "catalog#index"
  blacklight_for :catalog

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  devise_scope :user do
    get 'sign_in', to: 'users/sessions#new', as: :new_user_session
    get 'sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
  end

  get '/persons(/:page)', to: 'persons#index'
  post '/persons(/:page)', to: 'persons#search'

  resources :person, only: [:show, :create, :destroy] do
    resources :account, only: [:create, :destroy], controller: 'person/account'
    put '/account/:id', to: 'person/account#update'
    
    resources :membership, only: [:create, :destroy], controller: 'person/membership'
    put '/membership/:id', to: 'person/membership#update'
    
    get '/orcid', to: 'person#orcid', as: :person_orcid
#    get '/works(/:start_date)', to: 'person#works', as:person_works
  end
  put '/person(/:id)', to: 'person#update'

  resources :work, only: [:show, :create, :destroy]
  put '/work/:id', to: 'work#update'

  get '/organizations(/:page)', to: 'organizations#index'
  get '/organizations(/:page)', to: 'organizatiosn#search'
  
  get '/organization/:id', to: 'organizations#show', as: :organization_path
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
