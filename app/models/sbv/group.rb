# frozen_string_literal: true

#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::Group
  extend ActiveSupport::Concern

  included do # rubocop:disable Metrics/BlockLength
    root_types Group::Generalverband

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

    FQDN_REGEX = '(?=\A.{1,254}\z)(\A(([a-z0-9][a-z0-9\-]{0,61}[a-z0-9])\.)+([a-z0-9][a-z0-9\-]{0,61}[a-z0-9]))\z' # rubocop:disable Metrics/LineLength

    validates :hostname,
              uniqueness: { case_sensitive: false },
              format: { with: Regexp.new(FQDN_REGEX, Regexp::IGNORECASE) },
              allow_blank: true

    belongs_to :secondary_parent, class_name: 'Group'
    belongs_to :tertiary_parent, class_name: 'Group'

    before_validation :nullify_blank_hostname
    before_validation :downcase_hostname

    used_attributes << :secondary_parent_id << :tertiary_parent_id

    class << self
      def order_by_type_stmt_with_name(parent_group = nil)
        order_by_type_stmt_without_name(parent_group).gsub(/ lft$/, ' name')
      end

      alias_method_chain :order_by_type_stmt, :name
    end

    # potential other parents, dropdown data
    def self.secondary_parents
      where(type: %w(Group::Mitgliederverband Group::Regionalverband))
        .order(:type, :name)
        .select(:id, :name)
    end
  end

  def recognized_members
    manually_counted_members? ? manual_member_count : member_count
  end

  def mitgliederverband
    ancestors.find_by(type: Group::Mitgliederverband)
  end

  def regionalverband
    ancestors.find_by(type: Group::Regionalverband)
  end

  # actual other parents, secondary and tertiary
  def secondary_parents
    [
      Group.find_by(id: secondary_parent_id),
      Group.find_by(id: tertiary_parent_id)
    ].compact
  end

  def song_counts
    verein_sql = descendants.where(type: Group::Verein).without_deleted.select(:id).to_sql
    SongCount.joins(:concert).where("concerts.verein_id IN (#{verein_sql})")
  end

  def member_count
    return unless is_a?(Group::Verein)

    Group::VereinMitglieder::Mitglied.joins(:group).where(groups: { layer_group_id: id }).count
  end

  def hostname_from_hierarchy
    self_and_ancestors.find { |g| g.hostname.present? }.try(:hostname).presence
  end

  def nullify_blank_hostname
    self.hostname = nil if hostname.blank?
  end

  def downcase_hostname
    self.hostname = hostname.downcase if hostname.present?
  end

end
