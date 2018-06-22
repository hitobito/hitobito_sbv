module Sbv::Sheet::Group
  extend ActiveSupport::Concern

  included do
    tabs.insert(4,
                Sheet::Tab.new('group.suisa_tab',
                               :group_root_song_census_path,
                               params: { returning: true },
                               if: lambda do |view, group|
                                 group.is_a?(Group::Root) &&
                                   view.can?(:index, SongCensus)
                               end))
  end
end
