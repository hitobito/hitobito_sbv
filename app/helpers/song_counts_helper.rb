module SongCountsHelper

  def song_counts_count(object)
    content = []
    content << song_counts_update_button(object, :dec)
    style = 'padding: 0em 1em; display: inline-block; width: 1.7em; text-align: center'
    content << content_tag(:strong, class: '.count', style: style) do
      object.count.to_s
    end
    content << song_counts_update_button(object, :inc)
    safe_join(content)
  end

  def song_counts_update_button(object, action)
    count = action == :inc ? object.count + 1 : object.count - 1
    path = group_song_count_path(object.verein, object, song_count: { count: count })
    options = { method: :put, remote: true, data: { song_count: action } }
    options[:disabled] = true if action == :dec && object.count.zero?
    link_to(icon(action == :inc ? 'chevron-right' : 'chevron-left'), path, options)
  end

  def song_counts_export_dropdown
    Dropdown::SongCounts.new(self, params, :download).export
  end

end
