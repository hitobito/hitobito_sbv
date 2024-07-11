# frozen_string_literal: true

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

namespace :app do
  namespace :license do
    task :config do
      @licenser = Licenser.new("hitobito_sbv",
        "Schweizer Blasmusikverband",
        "https://github.com/hitobito/hitobito_sbv")
    end
  end
end
