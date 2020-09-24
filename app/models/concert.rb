# frozen_string_literal: true

#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

# == Schema Information
#
# Table name: concerts
#
#  id                   :integer          not null, primary key
#  name                 :string(255)      not null
#  verein_id            :integer          not null
#  mitgliederverband_id :integer
#  regionalverband_id   :integer
#  song_census_id       :integer
#  performed_at         :date
#  year                 :integer          not null
#  editable             :boolean          default(TRUE), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class Concert < ActiveRecord::Base

  acts_as_paranoid
  extend Paranoia::RegularScope

  belongs_to :song_census
  belongs_to :verein, class_name: 'Group::Verein'
  belongs_to :regionalverband, class_name: 'Group::Regionalverband'
  belongs_to :mitgliederverband, class_name: 'Group::Mitgliederverband'

  has_many :song_counts, dependent: :destroy

  after_initialize :set_readonly
  before_destroy :allow_soft_deletion

  before_validation :set_name
  before_validation :set_verband_ids, on: :create
  before_validation :remove_empty_song_count

  validates_by_schema except: [:name]
  validates :name, length: { maximum: 255 }

  accepts_nested_attributes_for :song_counts, allow_destroy: true

  include I18nEnums
  REASONS = %w(joint_play not_playable otherwise_billed).freeze
  i18n_enum :reason, REASONS, scopes: true, queries: true

  scope :in, ->(year) { where(year: year) }
  default_scope { order(performed_at: :desc) }

  def to_s
    name
  end

  def played?
    self[:reason].nil?
  end

  private

  def set_name
    return if name.present?

    self.name = I18n.t('activerecord.models.concert.without_date')
  end

  def remove_empty_song_count
    self.song_counts = song_counts.reject(&:empty?)
  end

  def set_readonly
    readonly! unless editable?
  end

  def set_verband_ids
    return if verein.blank?

    case verein.parent
    when Group::Regionalverband
      self.regionalverband_id = verein.parent.id
      self.mitgliederverband_id = verein.parent.parent.id
    when Group::Mitgliederverband
      self.mitgliederverband_id = verein.parent.id
    end
  end

  def allow_soft_deletion
    if changes.empty?
      @readonly = false
    end
  end

end
