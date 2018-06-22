# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

Rails.application.routes.draw do

  extend LanguageRouteScope

  language_scope do
    # Define wagon routes here

    resources :songs
    resources :groups do
      scope module: 'song_census_evaluation' do
        get 'root' => 'root#show', as: :root_song_census
        get 'verein' => 'verein#show', as: :verein_song_census
      end
    end
  end

end
