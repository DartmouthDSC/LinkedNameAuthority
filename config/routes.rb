Rails.application.routes.draw do
  root to: redirect('admin')

  devise_for :users, controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
              
  devise_scope :user do
    get '/sign_in', to: 'users/sessions#new', as: :new_user_session
    get '/sign_out', to: 'users/sessions#destroy', as: :destroy_user_session
  end

  # Routing update only to PUT
  concern :updateable do
    put :update, on: :member
  end
    
  # Collections
  concern :collections do 
    # Persons Collection
    get '/persons(/:page)', to: 'persons#index', as: :persons
    post '/persons(/:page)', to: 'persons#search'

    # Organizations
    get '/organizations(/:page)', to: 'organizations#index', as: :organizations
    post '/organizations(/:page)', to: 'organizations#search'
    
    # Works
    get '/works(/:page)', to: 'works#index', as: :works
    post '/works(/:page)', to: 'works#search'
    
    # Recent Works Collections convenience function
    constraints start_date:  /\d{4}-\d{2}-\d{2}/ do 
      get '/works/:start_date(/:page)', to: 'works#index'
      post '/works/:start_date(/:page)', to:'works#search'
    end
  end  

  namespace :admin do
    root action: 'index'
    get '/person', to: redirect('admin/persons')
    get '/work', to: redirect('admin/works')
    get '/organization', to: redirect('admin/organizations')
    
    concerns :collections

    resources :person, :organization, :work, only: :show
  end

  mount Hydra::RoleManagement::Engine, at: '/admin'
  
  concerns :collections
  
  # Person, Person Accounts, Person Memberships, Person ORCID account
  resources :person, only: [:show, :create, :destroy], concerns: :updateable do
    resources :account, only: [:create, :destroy], concerns: :updateable
    get :orcid, to: 'person/account#orcid'

    resources :membership, only: [:create, :destroy], controller: 'person/membership',
              concerns: :updateable

    # Person's Works Collection
    get '/works(/:start_date)', to: 'person/works#index', as: :works,
        constraints: { start_date: /\d{4}-\d{2}-\d{2}/ }
    get '/works/feed', to: 'person/works#feed', as: :works_feed,
        constraints: lambda { |request|
      (style = request.params[:style]) ? style.match(/apa|mla/) : true
    }
  end

  # Work, Work License
  resources :work, only: [:show, :create, :destroy], concerns: :updateable do
    resources :license, only: [:create, :destroy], controller: 'work/license',
              concerns: :updateable
  end

  # Organization, Organization Account
  resources :organization, only: [:show, :create, :destroy], concerns: :updateable do
    resources :account, only: [:create, :destroy], concerns: :updateable

    post '/end', to: 'change_event#terminate', as: :end
  end
  
  # Change Events
  post '/organization/:id_from/change_to/:id_to', to: 'change_event#create', as: :change_event
end
