# frozen_string_literal: true

#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module HitobitoSbv
  class Wagon < Rails::Engine
    include Wagons::Wagon

    # Set the required application version.
    app_requirement '>= 0'

    # Add a load path for this specific wagon
    config.autoload_paths += %W[
      #{config.root}/app/abilities
      #{config.root}/app/domain
      #{config.root}/app/jobs
      #{config.root}/app/validators
    ]

    config.to_prepare do # rubocop:disable Metrics/BlockLength
      # extend application classes here
      # models
      Group.include Sbv::Group
      Group.include Sbv::Group::NestedSet
      Person.include Sbv::Person
      Role.include Sbv::Role
      Subscription.prepend Sbv::Subscription
      MailingList.prepend Sbv::MailingList

      ### controllers
      GroupsController.permitted_attrs += [:vereinssitz, :founding_year,
                                           :correspondence_language, :besetzung,
                                           :klasse, :unterhaltungsmusik,
                                           :secondary_parent_id, :tertiary_parent_id,
                                           :subventionen, :hostname,
                                           :buv_lohnsumme, :nbuv_lohnsumme]

      PeopleController.permitted_attrs += [:profession, :correspondence_language,
                                           :personal_data_usage]

      Person::HistoryController.prepend Sbv::Person::HistoryController
      DeviseController.include HostnamedGroups

      ### helpers
      admin = NavigationHelper::MAIN.find { |opts| opts[:label] == :admin }
      admin[:active_for] << 'songs'

      index_admin = NavigationHelper::MAIN.index { |opts| opts[:label] == :admin }
      NavigationHelper::MAIN.insert(
        index_admin,
        label: :help,
        icon_name: :'info-circle',
        url: :help_path
      )

      GroupsHelper.include Sbv::GroupsHelper
      GroupDecorator.prepend Sbv::GroupDecorator
      StandardFormBuilder.include Sbv::StandardFormBuilder

      ### sheets
      Sheet::Group.include Sbv::Sheet::Group
      Sheet::Event.include Sbv::Sheet::Event

      ### jobs
      Export::SubgroupsExportJob.prepend Sbv::Export::SubgroupsExportJob

      ### mailers
      Person::LoginMailer.prepend Sbv::Person::LoginMailer
      ApplicationMailer.prepend Sbv::ApplicationMailer

      ### domain
      Export::Tabular::Groups::Row.include Sbv::Export::Tabular::Groups::Row
      Export::Tabular::Groups::List.prepend Sbv::Export::Tabular::Groups::List
      Export::Tabular::People::PeopleFull.include Sbv::Export::Tabular::People::PeopleFull

      MailRelay::Lists.prepend Sbv::MailRelay::Lists

      ### abilities
      RoleAbility.include Sbv::RoleAbility
      GroupAbility.include Sbv::GroupAbility

      # festival_participation allows to manage your group's participation to a festival
      # uv_lohnsumme allows to manage the salary amount for the accident insurance
      Role::Permissions << :festival_participation << :uv_lohnsumme

      # load this class after all abilities have been defined
      AbilityDsl::UserContext::GROUP_PERMISSIONS << :song_census << :festival_participation
      AbilityDsl::UserContext::LAYER_PERMISSIONS                 << :festival_participation

      AbilityDsl::UserContext::GROUP_PERMISSIONS << :uv_lohnsumme
      AbilityDsl::UserContext::LAYER_PERMISSIONS << :uv_lohnsumme

      # lastly, register the abilities (could happen earlier, it's just a nice conclusion here)
      Ability.store.register SongAbility
      Ability.store.register Event::GroupParticipationAbility
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
