module Sbv::Sheet::Group
  extend ActiveSupport::Concern

  included do
    tabs.insert(4,
                Sheet::Tab.new('group.suisa_tab',
                               :group_root_song_census_path,
                               if: lambda do |view, group|
                                 !group.is_a?(Group::Verein) &&
                                   view.can?(:index, SongCensus)
                               end),

                Sheet::Tab.new('group.suisa_tab',
                               :group_song_counts_path,
                               if: lambda do |view, group|
                                 group.is_a?(Group::Verein) &&
                                   view.can?(:index, SongCensus)
                               end))

  end
end
