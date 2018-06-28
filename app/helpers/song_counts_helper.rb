module SongCountsHelper

  def song_counts_count(object)
    content = []
    content << song_counts_update_button(object, :plus, :inc)
    content << content_tag(:strong, class: '.count', style: 'padding: 0em 1em 0em 1em') do
      object.count.to_s
    end
    content << song_counts_update_button(object, :minus, :dec)
    safe_join(content)
  end

  def song_counts_update_button(object, icon, action)
    count = action == :inc ? object.count + 1 : object.count - 1
    path = group_song_count_path(object.verein, object, song_count: { count: count })
    options = { method: :put, remote: true, data: { song_count: action } }
    options[:disabled] = true if action == :dec && object.count.zero?
    action_button('', path, icon, options)
  end

end
