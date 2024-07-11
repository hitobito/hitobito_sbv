#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

Fabrication.configure do |config|
  config.fabricator_path = ["spec/fabricators",
    "../hitobito_sbv/spec/fabricators"]
  config.path_prefix = Rails.root
end
