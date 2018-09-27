#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sheet
  class Concert < Base
    self.parent_sheet = Sheet::Group

    delegate :t, to: :I18n

    def title
      t('concerts.actions_index.title')
    end
  end
end
