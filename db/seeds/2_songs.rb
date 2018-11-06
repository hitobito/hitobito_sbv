# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'csv'

CSV::Converters[:nil] = lambda { |f| f == "\\N" ? nil : f.encode(CSV::ConverterEncoding) rescue f }
CSV::Converters[:all] = [:numeric, :nil]

if Wagons.find('sbv').root.join('db/seeds/production/suisa_werke.csv').exist?
  CSV.parse(Wagons.find('sbv').root.join('db/seeds/production/suisa_werke.csv').read.gsub('\"', '""'), headers: true, converters: :all).each do |song|
    Song.seed_once(:suisa_id, song.to_hash)
  end
end
