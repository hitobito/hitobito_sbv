#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class Event::Festival < Event

  self.used_attributes -= [
    :application_conditions,
    :applications_cancelable,
    :cost,
    :external_applications,
    :maximum_participants,
    :motto,
    :signature,
    :signature_confirmation,
    :signature_confirmation_text
  ]

end
