#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Event::GroupParticipationData
  MUSIC_CLASSIFICATIONS = [
    {
      style: 'concert_music',
      types: {
        'harmony'                    => %w(highest first second third fourth),
        'brass_band'                 => %w(highest first second third fourth),
        'fanfare_benelux_harmony'    => %w(first second third),
        'fanfare_benelux_brass_band' => %w(first second third),
        'fanfare_mixte_harmony'      => %w(fourth),
        'fanfare_mixte_brass_band'   => %w(fourth)
      }
    },
    {
      style: 'contemporary_music',
      types: {
        'harmony'    => %w(high medium low),
        'brass_band' => %w(high medium low)
      }
    },
    {
      style: 'parade_music',
      types: {
        'traditional_parade' => %w(),
        'show_parade'        => %w()
      }
    }
  ].freeze

  # these two constants should, if they ever need to change, be made
  # configurable through additional attributes or a relation on Event::Date
  # This duplication in structure with the MUSIC_CLASSIFICATIONS is actually a
  # dependency.
  AVAILABLE_PLAY_DAYS = { thursday: 4, friday: 5, saturday: 6, sunday: 0 }.freeze
  MUSIC_LEVEL_PLAY_DAYS = {
    'concert_music' => {
      'harmony' => {
        'highest' => AVAILABLE_PLAY_DAYS.values_at(:friday, :saturday, :sunday),
        'first'   => AVAILABLE_PLAY_DAYS.values,
        'second'  => AVAILABLE_PLAY_DAYS.values,
        'third'   => AVAILABLE_PLAY_DAYS.values,
        'fourth'  => AVAILABLE_PLAY_DAYS.values_at(:sunday)
      },
      'brass_band' => {
        'highest' => AVAILABLE_PLAY_DAYS.values_at(:thursday, :friday),
        'first'   => AVAILABLE_PLAY_DAYS.values,
        'second'  => AVAILABLE_PLAY_DAYS.values,
        'third'   => AVAILABLE_PLAY_DAYS.values,
        'fourth'  => AVAILABLE_PLAY_DAYS.values_at(:thursday)
      },
      'fanfare_benelux_harmony' => {
        'first'  => AVAILABLE_PLAY_DAYS.values_at(:thursday),
        'second' => AVAILABLE_PLAY_DAYS.values_at(:thursday),
        'third'  => AVAILABLE_PLAY_DAYS.values_at(:thursday, :friday)
      },
      'fanfare_benelux_brass_band' => {
        'first'  => AVAILABLE_PLAY_DAYS.values_at(:thursday),
        'second' => AVAILABLE_PLAY_DAYS.values_at(:thursday),
        'third'  => AVAILABLE_PLAY_DAYS.values_at(:thursday, :friday)
      },
      'fanfare_mixte_harmony' => {
        'fourth' => AVAILABLE_PLAY_DAYS.values_at(:thursday)
      },
      'fanfare_mixte_brass_band' => {
        'fourth' => AVAILABLE_PLAY_DAYS.values_at(:thursday)
      }
    },
    'contemporary_music' => {
      'harmony' => {
        'high'   => AVAILABLE_PLAY_DAYS.values_at(:saturday),
        'medium' => AVAILABLE_PLAY_DAYS.values_at(:saturday, :sunday),
        'low'    => AVAILABLE_PLAY_DAYS.values_at(:thursday)
      },
      'brass_band' => {
        'high'   => AVAILABLE_PLAY_DAYS.values_at(:sunday),
        'medium' => AVAILABLE_PLAY_DAYS.values_at(:saturday),
        'low'    => AVAILABLE_PLAY_DAYS.values_at(:friday)
      }
    },
    'parade_music' => {}
  }.freeze
end
