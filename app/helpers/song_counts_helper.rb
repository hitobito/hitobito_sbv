module SongCountsHelper

  def song_counts_count(object)
    path = group_song_count_path(object.verein, object)
    content = []
    content << action_button('', path, :plus, method: :put, remote: true)
    content << content_tag(:strong, " #{object.count} ")
    content << action_button('', path, :minus, method: :put, remote: true)
    safe_join(content)
  end

end
