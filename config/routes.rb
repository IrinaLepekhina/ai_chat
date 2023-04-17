#  https://guides.rubyonrails.org/routing.html

# This file defines the routing configuration for the Rails application.
# The `meals` resource is defined within the `api/v1` scope.

Rails.application.routes.draw do

  root to: 'api/v1/welcome#index'

  namespace :api do
    scope module: :v1 do
      get 'welcome/index'

      resources :meals, only: %i[new], constraints: { format: 'html' }
      resources :meals, only: %i[index create show], constraints: { format: 'json' }
      resources :meals, only: %i[index create show], constraints: { format: 'html' }

    end
  end
end
