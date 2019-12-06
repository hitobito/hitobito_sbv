class Event::GroupParticipation < ActiveRecord::Base
  self.demodulized_route_keys = true

  ### ASSOCIATIONS

  belongs_to :event
  belongs_to :group

  belongs_to :group_application, inverse_of: :group_participation, dependent: :destroy, validate: true

  ### VALIDATIONS

  validates_by_schema
  validates :group_id, uniqueness: { scope: :event_id }
end
