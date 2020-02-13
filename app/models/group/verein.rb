#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.
# == Schema Information
#
# Table name: groups
#
#  id                          :integer          not null, primary key
#  parent_id                   :integer
#  lft                         :integer
#  rgt                         :integer
#  name                        :string(255)      not null
#  short_name                  :string(31)
#  type                        :string(255)      not null
#  email                       :string(255)
#  address                     :string(1024)
#  zip_code                    :integer
#  town                        :string(255)
#  country                     :string(255)
#  contact_id                  :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  deleted_at                  :datetime
#  layer_group_id              :integer
#  creator_id                  :integer
#  updater_id                  :integer
#  deleter_id                  :integer
#  require_person_add_requests :boolean          default(FALSE), not null
#  vereinssitz                 :string(255)
#  founding_year               :integer
#  correspondence_language     :string(5)
#  besetzung                   :string(255)
#  klasse                      :string(255)
#  unterhaltungsmusik          :string(255)
#  subventionen                :string(255)
#  swoffice_id                 :integer
#  secondary_parent_id         :integer
#  tertiary_parent_id          :integer
#  description                 :text(65535)
#  logo                        :string(255)
#  hostname                    :string(255)
#

class Group::Verein < ::Group

  HIDDEN_ROOT_VEREIN_NAME = 'Ehemalige aus Verlauf'.freeze

  self.layer = true
  self.default_children = [Group::VereinVorstand,
                           Group::VereinKontakte,
                           Group::VereinMitglieder,
                           Group::VereinMusikkommission]

  children Group::VereinVorstand,
           Group::VereinMusikkommission,
           Group::VereinMitglieder,
           Group::VereinArbeitsgruppe,
           Group::VereinKontakte

  self.used_attributes += [:founding_year,
                           :correspondence_language,
                           :besetzung,
                           :klasse,
                           :unterhaltungsmusik,
                           :subventionen,
                           :recognized_members]

  has_many :concerts, dependent: :destroy
  has_many :song_counts, through: :concerts

  has_many :group_participations, dependent: :destroy,
                                  class_name: 'Event::GroupParticipation',
                                  foreign_key: 'group_id'

  def self.hidden
    root = Group::Root.first
    verein = Group::Verein.deleted.find_by(name: HIDDEN_ROOT_VEREIN_NAME, parent: root)
    return verein if verein

    # NOTE: we piggy-back on created_at to avoid default children to be created
    Group::Verein.create!(name: HIDDEN_ROOT_VEREIN_NAME,
                          parent: root,
                          created_at: 1.minute.ago,
                          deleted_at: Time.zone.now)
  end


  # TODO: Validierungen der verschiedenen Values, refactoring, exports

  def last_played_song_ids
    year = Time.zone.now.year

    SongCount.where(concert: concerts.in([year, year - 1]))
             .pluck(:song_id)
             .uniq
  end

  def suisa_admins
    Person.joins(:roles)
          .where("roles.type = 'Group::Verein::SuisaAdmin' AND roles.group_id = #{id}")
  end

  ### ROLES

  class Admin < Role::Admin
    self.permissions = [:layer_and_below_full, :festival_participation]
  end

  class Conductor < Role
    self.permissions = [:contact_data]
  end

  class SuisaAdmin < Sbv::Role::SuisaAdmin
  end

  roles Admin, Conductor, SuisaAdmin
end
