#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::Sheet::Group
  extend ActiveSupport::Concern

  included do
    tabs.insert(4,
                Sheet::Tab.new('group.suisa_tab',
                               :group_song_censuses_path,
                               if: lambda do |view, group|
                                 !group.is_a?(Group::Verein) && group.layer? &&
                                   view.can?(:manage_song_census, group)
                               end),
                Sheet::Tab.new('group.suisa_tab',
                               :group_concerts_path,
                               if: lambda do |view, group|
                                 group.is_a?(Group::Verein) &&
                                   (view.can?(:index_song_counts, group) ||
                                   view.can?(:manage_song_census, group))
                               end))
    tabs.insert(5,
                Sheet::Tab.new('group.festival_tab',
                               :festivals_group_events_path,
                               params: { returning: true },
                               if: lambda do |view, group|
                                 group.event_types.include?(::Event::Festival) &&
                                   view.can?(:'index_event/festivals', group)
                               end))
  end
end
