# encoding: utf-8

#  Copyright (c) 2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

# == Schema Information
#
# Table name: roles
#
#  id         :integer          not null, primary key
#  person_id  :integer          not null
#  group_id   :integer          not null
#  type       :string(255)      not null
#  label      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#


class Role::MitgliederMitglied < Role
  self.permissions = [:layer_read]

  after_save :update_active_years_on_person
  after_destroy :update_active_years_on_person

  private

  def update_active_years_on_person
    person.send(:cache_active_years)
  end

end
