module Sbv::Role
  extend ActiveSupport::Concern

  included do
    validates :created_at, presence: true, if: :deleted_at

    validates_date :created_at,
                   if: :deleted_at,
                   on_or_before: :deleted_at,
                   on_or_before_message: :cannot_be_later_than_deleted_at

    validates_date :created_at,
                   allow_nil: true,
                   on_or_before: -> { Time.zone.today },
                   on_or_before_message: :cannot_be_later_than_today
  end

  Role::Types::Permissions << :song_census

  class SuisaAdmin < ::Role
    self.permissions = [:group_read, :song_census]
  end

end
