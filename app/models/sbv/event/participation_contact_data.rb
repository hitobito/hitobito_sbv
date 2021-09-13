# frozen_string_literal: true

#  Copyright (c) 2021, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::Event::ParticipationContactData
  extend ActiveSupport::Concern

  included do
    Event::ParticipationContactData.contact_attrs << :correspondence_language

    delegate(*Event::ParticipationContactData.contact_attrs, to: :person)
  end
end
