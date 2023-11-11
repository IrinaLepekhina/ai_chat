#  https://guides.rubyonrails.org/routing.html

# This file defines the routing configuration for the Rails application.
# The `products` resource is defined within the `api/v1` scope.
Rails.application.routes.draw do

  root to: 'api/v1/welcome#index'
  
  namespace :api do
    get  'login', to: 'authentication#new'
    post 'login', to: 'authentication#login',                 constraints: { format: /(json|html)/ }
    delete 'logout', to: 'authentication#logout',             constraints: { format: /(json|html)/ }
  # post 'refresh_token', to: 'authentication#refresh_token', constraints: { format: /(json)/ }
    
    scope module: :v1 do
      get 'boxstore/api_versions', to: 'boxstore#api_versions'
      get 'boxstore/credentials', to: 'boxstore#credentials'
   
      get 'welcome/index'

      post 'signup', to: 'users#create',                  constraints: { format: :json}

      resources :conversations, only: %i[create index show destroy] do
        resources :chat_entries, only: %i[create],         constraints: { format: /(json|html)/ }
      end

      resources :prompts, only: %i[new create index show], constraints: { format: :html}
    end
  end
end