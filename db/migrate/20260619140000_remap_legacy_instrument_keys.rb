# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class RemapLegacyInstrumentKeys < ActiveRecord::Migration[8.0]
  LEGACY_KEY = "saxophon"
  TARGET_KEY = "saxophon_alt"

  def up
    say_with_time "remap legacy instrument key #{LEGACY_KEY} to #{TARGET_KEY}" do
      Role.where(instrument: LEGACY_KEY).update_all(instrument: TARGET_KEY)
    end
  end

  def down
    Role.where(instrument: TARGET_KEY).update_all(instrument: LEGACY_KEY)
  end
end
