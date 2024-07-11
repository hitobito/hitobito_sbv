#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

# Rename person Faker for overwrite purpose
Fabrication.manager.schematics[:person_without_birthday] = Fabrication.manager.schematics.delete(:person)

Fabricator(:person, from: :person_without_birthday) do
  birthday { Faker::Date.birthday }
  correspondence_language { "de" }
end
