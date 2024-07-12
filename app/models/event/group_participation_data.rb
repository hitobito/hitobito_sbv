# frozen_string_literal: true

#  Copyright (c) 2019-2024, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Event::GroupParticipationData
  MUSIC_CLASSIFICATIONS = [
    {
      style: "concert_music",
      types: {
        "harmony" => %w[highest first second third fourth],
        "brass_band" => %w[highest first second third fourth],
        "fanfare_benelux" => %w[first second third],
        "fanfare_mixte" => %w[fourth]
      }
    },
    {
      style: "contemporary_music",
      types: {
        "harmony" => %w[high medium low],
        "brass_band" => %w[high medium low]
      }
    },
    {
      style: "parade_music",
      types: {
        "no_parade" => %w[],
        "traditional_parade" => %w[],
        "show_parade" => %w[]
      }
    }
  ].freeze
end
