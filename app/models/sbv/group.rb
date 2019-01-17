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

    BESETZUNGEN = %w(brass_band harmonie fanfare_benelux fanfare_mixte tambour_percussion).freeze
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

    belongs_to :secondary_parent, class_name: 'Group'
    belongs_to :tertiary_parent, class_name: 'Group'

    used_attributes << :secondary_parent_id << :tertiary_parent_id

    class << self
      def secondary_parents
        where(type: %w(Group::Mitgliederverband Group::Regionalverband))
          .order(:name)
          .select(:id, :name)
      end

      def order_by_type_stmt_with_name(parent_group = nil)
        order_by_type_stmt_without_name(parent_group).gsub(/ lft$/, ' name')
      end

      alias_method_chain :order_by_type_stmt, :name
    end
  end


  def song_counts
    verein_ids = descendants.where(type: Group::Verein).pluck(:id)
    SongCount.joins(:concert).where("concerts.verein_id IN (#{verein_ids.join(',')})")
  end

  def recognized_members
    return unless is_a?(Group::Verein)

    Group::VereinMitglieder::Mitglied.joins(:group).where(groups: { layer_group_id: id }).count
  end

  def secondary_parents
    [
      Group.find_by(id: secondary_parent_id),
      Group.find_by(id: tertiary_parent_id)
    ].compact
  end

end
