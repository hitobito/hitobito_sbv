# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module HitobitoSbv
  class Wagon < Rails::Engine
    include Wagons::Wagon

    # Set the required application version.
    app_requirement '>= 0'

    # Add a load path for this specific wagon
    config.autoload_paths += %W( #{config.root}/app/abilities
                                 #{config.root}/app/domain
                                 #{config.root}/app/jobs
                               )

    config.to_prepare do
      # rubocop:disable SingleSpaceBeforeFirstArg
      # extend application classes here
      # models
      Group.send        :include, Sbv::Group
      Person.send       :include, Sbv::Person
      Role.send         :include, Sbv::Role

      ### controllers
      GroupsController.permitted_attrs += [:vereinssitz, :founding_year,
                                           :correspondence_language, :besetzung,
                                           :klasse, :unterhaltungsmusik,
                                           :subventionen, :reported_members]

      PeopleController.permitted_attrs += [:profession, :correspondence_language]

      ### helpers
      GroupsHelper.send :include, Sbv::GroupsHelper

      ### sheets
      Sheet::Group.send :include, Sbv::Sheet::Group

      ### domain
      Export::Tabular::Groups::Row.send :include, Sbv::Export::Tabular::Groups::Row
      Export::Tabular::Groups::List.send :include, Sbv::Export::Tabular::Groups::List

      # load this class after all abilities have been defined
      AbilityDsl::UserContext::GROUP_PERMISSIONS << :song_census
      Ability.store.register SongAbility

      # rubocop:enable SingleSpaceBeforeFirstArg
    end

    initializer 'sbv.add_settings' do |_app|
      Settings.add_source!(File.join(paths['config'].existent, 'settings.yml'))
      Settings.reload!
    end

    initializer 'sbv.add_inflections' do |_app|
      ActiveSupport::Inflector.inflections do |inflect|
        inflect.irregular 'song_census', 'song_censuses'
      end
    end

    private

    def seed_fixtures
      fixtures = root.join('db', 'seeds')
      ENV['NO_ENV'] ? [fixtures] : [fixtures, File.join(fixtures, Rails.env)]
    end

  end
end
