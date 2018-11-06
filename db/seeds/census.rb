#  Copyright (c) 2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

[2019].each do |year|
  SongCensus.seed_once(:year) do |census|
    census.year = year
    census.start_at = Date.new(year - 1, 12, 1)
    census.finish_at = Date.new(year, 11).end_of_month
  end
end
