# frozen_string_literal: true

#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::Sheet::Event
  extend ActiveSupport::Concern

  included do
    tab 'events.group_participations.list',
        :group_event_group_participations_path
  end
end
