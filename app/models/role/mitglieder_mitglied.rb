#  Copyright (c) 2018-2020, Schweizer Blasmusikverband. This file is part of
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

  attr_accessor :historic_membership

  after_save :update_active_years_on_person
  after_destroy :update_active_years_on_person

  validates_date :deleted_at,
                 if: :historic_membership,
                 allow_nil: false,
                 on_or_before: -> { Time.zone.today },
                 on_or_before_message: :cannot_be_later_than_today

  private

  def update_active_years_on_person
    person.cache_active_years
    person.save(validate: false)
  end

end
