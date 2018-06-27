# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

namespace :songs do
  task :import, [:csv_songs_filepath] => :environment do |_t, args|
    puts Songs::Importer.new(args[:csv_songs_filepath]).compose
  end
end
