#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

Rails.application.routes.draw do

  extend LanguageRouteScope

  language_scope do
    # Define wagon routes here

    resources :songs
    resources :groups, only: [] do
      member do
        get :subverein_select
      end

      get 'export_lohnsummen' => 'lohnsummen#show'

      resources :song_counts
      resources :concerts do
        collection do
          post 'submit'
        end
      end

      resources :song_censuses, only: [:new, :create, :index] do
        post 'remind', to: 'song_censuses#remind'
      end
      resource :roles, only: [] do
        post 'create_history_member'
      end
      resources :history_roles, only: [:create, :destroy]
    end
    get '/groups/query' => 'groups/query#index', as: :query_groups

    get 'help' => 'help#index'
  end

end
