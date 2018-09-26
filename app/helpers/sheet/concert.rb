#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sheet
  class Concert < Base
    self.parent_sheet = Sheet::Group

    def render_tabs
      content_tag(:ul, class: 'nav nav-sub') do
        safe_join(tabs) do |title, path|
          content_tag(:li,
                      link_to(title, path),
                      class: active(path) ? 'active' : nil)
        end
      end
    end

    delegate :t, to: :I18n

    def tabs
      [
        [t('concerts.actions_index.concerts'), view.group_concerts_path],
        [t('concerts.actions_index.summary'), view.group_song_counts_path]
      ]
    end

    def title
      t('concerts.actions_index.title')
    end

    def active(path)
      path == current_nav_path
    end

  end
end
