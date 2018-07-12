module SongCountsHelper

  def song_counts_count(object)
    content = []
    content << song_counts_update_button(object, :dec)
    content << content_tag(:strong, class: 'count') do
      object.count.to_s
    end
    content << song_counts_update_button(object, :inc)
    safe_join(content)
  end

  def song_counts_update_button(object, action)
    count = action == :inc ? object.count + 1 : object.count - 1
    path = group_song_count_path(object.verein, object, song_count: { count: count })
    icon = icon(action == :inc ? 'chevron-right' : 'chevron-left')
    options = song_counts_update_options(object, action)
    link_to(icon, path, options)
  end

  def song_counts_export_dropdown
    Dropdown::SongCounts.new(self, params, :download).export
  end

  private

  def song_counts_update_options(object, action)
    options = { method: :put, remote: true, data: { song_count: action } }
    if action == :dec && object.count <= 0 || action == :inc && object.count >= 30
      options[:class] = 'disabled'
      options[:style] = 'pointer-events: none'
    end
    options
  end

end
