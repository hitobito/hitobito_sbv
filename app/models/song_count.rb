# frozen_string_literal: true

#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.
# == Schema Information
#
# Table name: song_counts
#
#  id         :integer          not null, primary key
#  song_id    :integer          not null
#  year       :integer          not null
#  count      :integer          default(1), not null
#  concert_id :integer
#

class SongCount < ActiveRecord::Base
  belongs_to :song
  belongs_to :concert, touch: true

  validates :count,
    numericality: {greater_than_or_equal_to: 1, less_than_or_equal_to: 30}, if: :count
  # rubocop:todo Rails/UniqueValidationWithoutIndex
  validates :song_id, uniqueness: {scope: :concert}
  # rubocop:enable Rails/UniqueValidationWithoutIndex

  delegate :title, :composed_by, :arranged_by, :published_by, :suisa_id,
    to: :song
  delegate :verein, :verein_id, :mitgliederverband, :mitgliederverband_id, :song_census,
    to: :concert

  scope :in, ->(year) { where(year: year) }
  scope :ordered, -> { joins(:song).order("songs.title") }

  def to_s
    song.to_s
  end

  def empty?
    count.to_i.zero?
  end
end
