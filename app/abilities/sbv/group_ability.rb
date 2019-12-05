module Sbv::GroupAbility
  extend ActiveSupport::Concern

  included do
    on(Group) do
      permission(:any).may(:'index_event/festivals').all
    end
  end
end
