#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class Event::GroupParticipation < ActiveRecord::Base
  self.demodulized_route_keys = true

  ### ASSOCIATIONS

  belongs_to :event
  belongs_to :group

  ### VALIDATIONS

  validates_by_schema
  validates :group_id, uniqueness: { scope: :event_id }
end
