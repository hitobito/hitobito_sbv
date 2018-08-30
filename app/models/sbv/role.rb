module Sbv::Role
  extend ActiveSupport::Concern

  included do
    validates :created_at, presence: true, if: :deleted_at
    validate :created_at_has_to_be_earlier_or_equal_than_today
    validate :created_at_has_to_be_earlier_or_equal_than_deleted_at
  end

  Role::Types::Permissions << :song_census

  class SuisaAdmin < ::Role
    self.permissions = [:group_read, :song_census]
  end

  private

  def created_at_has_to_be_earlier_or_equal_than_deleted_at
    if deleted_at && (!created_at || created_at > deleted_at)
      errors.add(:created_at, I18n.t('errors.messages.cannot_be_later_than_deleted_at'))
    end
  end

  def created_at_has_to_be_earlier_or_equal_than_today
    if created_at && created_at.to_date > Time.zone.today
      errors.add(:created_at, I18n.t('errors.messages.cannot_be_later_than_today'))
    end
  end

end
