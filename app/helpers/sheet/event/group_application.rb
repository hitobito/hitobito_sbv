#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sheet
  class Event
    class GroupParticipation < Base
      self.parent_sheet = Sheet::Event

      delegate :t, to: :I18n

      def title
        t('group_participations.actions_new.title')
      end
    end
  end
end
