# encoding: utf-8
# == Schema Information
#
# Table name: songs
#
#  id           :integer          not null, primary key
#  title        :string(255)      not null
#  composed_by  :string(255)      not null
#  arranged_by  :string(255)
#  published_by :string(255)
#


#  Copyright (c) 2012-2013, Puzzle ITC GmbH. This file is part of
#  hitobito_generic and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_generic.

class Song < ActiveRecord::Base

  validates_by_schema

end
