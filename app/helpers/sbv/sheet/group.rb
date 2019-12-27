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
                Sheet::Tab.new('group.festival_tab', :festival_group_events_path,
                               params: { returning: true },
                               if: lambda do |view, group|
                                 group.event_types.include?(::Event::Festival) &&
                                   view.can?(:'index_event/festivals', group)
                               end),
                Sheet::Tab.new('group.festival_tab', :group_our_festival_participations_path,
                               params: { returning: true },
                               if: lambda do |view, group|
                                 # Event::Festival.participatable(group).present? &&
                                 view.can?(:manage_festival_application, group)
                               end))
  end
end
