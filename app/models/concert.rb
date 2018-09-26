#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.
#
# == Schema Information
#
# Table name: concerts
#
#  id                   :integer          not null, primary key
#  name                 :string           not null
#  verein_id            :integer          not null
#  mitgliederverband_id :integer
#  regionalverband_id   :integer
#  song_census_id       :integer
#  performed_at         :date
#  year                 :integer          not null
#  editable             :boolean          default(TRUE), not null
#

class Concert < ActiveRecord::Base
  belongs_to :song_census
  belongs_to :verein, class_name: 'Group::Verein'
  belongs_to :regionalverband, class_name: 'Group::Regionalverband'
  belongs_to :mitgliederverband, class_name: 'Group::Mitgliederverband'

  has_many :song_counts, dependent: :destroy

  after_initialize :set_readonly

  before_validation :set_name, unless: 'name.present?'
  before_validation :set_verband_ids, on: :create, if: :verein
  before_validation :remove_empty_song_count

  validates_by_schema
  validates :name, presence: true, uniqueness: { scope: [:verein, :year] }

  accepts_nested_attributes_for :song_counts, allow_destroy: true

  scope :in, ->(year) { where(year: year) }
  default_scope { order(performed_at: :desc) }

  def to_s
    name
  end

  private

  def set_name
    100.times do |i|
      self.name = "#{I18n.t('activerecord.models.concert.one')} ##{i + 1}"
      break if valid? || errors[:name].blank?
    end
  end

  def remove_empty_song_count
    self.song_counts = song_counts.reject(&:empty?)
  end

  def set_readonly
    readonly! unless editable?
  end

  def set_verband_ids
    case verein.parent
    when Group::Regionalverband
      self.regionalverband_id = verein.parent.id
      self.mitgliederverband_id = verein.parent.parent.id
    when Group::Mitgliederverband
      self.mitgliederverband_id = verein.parent.id
    end
  end

end
