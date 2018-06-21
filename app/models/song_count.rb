# encoding: utf-8

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
