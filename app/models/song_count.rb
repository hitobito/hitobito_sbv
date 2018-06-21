# encoding: utf-8
# == Schema Information
#
# Table name: song_counts
#
#  id                      :integer          not null, primary key
#  census_id               :integer          not null
#  song_id                 :integer          not null
#  verein_id               :integer          not null
#  mitgliederverband_id_id :integer
#  regionalverband_id_id   :integer
#  count                   :integer          default(1), not null
#


#  Copyright (c) 2012-2013, Puzzle ITC GmbH. This file is part of
#  hitobito_generic and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_generic.

class SongCount < ActiveRecord::Base

  belongs_to :song
  belongs_to :song_census
  belongs_to :verein, class_name: 'Group::Verein'
  belongs_to :regionalverband, class_name: 'Group::Regionalverband'
  belongs_to :mitgliederverband, class_name: 'Group::Mitgliederverband'

  validates_by_schema

end
