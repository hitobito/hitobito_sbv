# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class RemapExpandedInstrumentKeys < ActiveRecord::Migration[8.0]
  REMAP = {
    "floete" => "querfloete",
    "horn" => "waldhorn"
  }.freeze

  def up
    REMAP.each do |legacy_key, target_key|
      say_with_time "remap instrument #{legacy_key} to #{target_key}" do
        Role.where(instrument: legacy_key).update_all(instrument: target_key)
      end
    end
  end

  def down
    REMAP.each do |legacy_key, target_key|
      Role.where(instrument: target_key).update_all(instrument: legacy_key)
    end
  end
end
