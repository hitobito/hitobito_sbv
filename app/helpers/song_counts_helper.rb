# frozen_string_literal: true
module SongCountsHelper

  def song_counts_update_button(action)
    icon = icon(action == :inc ? 'chevron-right' : 'chevron-left')
    link_to(icon, '#', class: "#{action}_song_count")
  end

  def song_counts_export_dropdown
    Dropdown::SongCounts.new(self, params, :download).export
  end

end
