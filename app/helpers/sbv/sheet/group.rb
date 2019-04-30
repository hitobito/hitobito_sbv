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

  end
end
