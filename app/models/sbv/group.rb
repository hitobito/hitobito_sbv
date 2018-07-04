# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::Group
  extend ActiveSupport::Concern

  included do
    root_types Group::Root

    include I18nSettable
    include I18nEnums

    BESETZUNGEN = %w(brass_band harmonie fanfare_benelux fanfare_mixte).freeze
    KLASSEN = %w(hoechste erste zweite dritte vierte).freeze
    UNTERHALTUNGSMUSIK = %w(oberstufe mittelstufe unterstufe).freeze

    i18n_enum :besetzung, BESETZUNGEN, key: :besetzungen
    i18n_enum :klasse, KLASSEN, key: :klassen
    i18n_enum :unterhaltungsmusik, UNTERHALTUNGSMUSIK, key: :unterhaltungsmusik_stufen

    i18n_setter :besetzung, (BESETZUNGEN + [nil])
    i18n_setter :klasse, (KLASSEN + [nil])
    i18n_setter :unterhaltungsmusik, (UNTERHALTUNGSMUSIK + [nil])

    validates :reported_members,
              numericality: { greater_than_or_equal_to: 0 }, if: :reported_members

  end

  def song_counts
    verein_ids = descendants.where(type: Group::Verein).pluck(:id)
    SongCount.where("verein_id IN (#{verein_ids.join(',')})")
  end

  def recognized_members
    return unless is_a?(Group::Verein)

    Group::VereinMitglieder::Mitglied.joins(:group).where(groups: { layer_group_id: id }).count
  end

end
