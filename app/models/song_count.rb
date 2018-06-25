# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.
# == Schema Information
#
# Table name: song_counts
#
#  id                      :integer          not null, primary key
#  song_id                 :integer          not null
#  verein_id               :integer          not null
#  mitgliederverband_id_id :integer
#  regionalverband_id_id   :integer
#  song_cenus_id           :integer
#  year                    :integer          not null
#  count                   :integer          default(1), not null
#

class SongCount < ActiveRecord::Base

  belongs_to :song
  belongs_to :song_census
  belongs_to :verein, class_name: 'Group::Verein'
  belongs_to :regionalverband, class_name: 'Group::Regionalverband'
  belongs_to :mitgliederverband, class_name: 'Group::Mitgliederverband'

  scope :in, ->(year) { where(year: year) }

  validates_by_schema

  validates :song_id, uniqueness: [:verein_id, :year]

  delegate :title, :composed_by, :arranged_by, :produced_by, to: :song

  def to_s
    song.to_s
  end

end
