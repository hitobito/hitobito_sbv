# frozen_string_literal: true

#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::PersonAbility
  extend ActiveSupport::Concern

  included do
    on(Person) do
      permission(:any).may(:destroy).if_mitgliederverbands_admin
    end
  end

  def if_mitgliederverbands_admin
    role_type?(Group::Mitgliederverband::Admin)
  end
end
