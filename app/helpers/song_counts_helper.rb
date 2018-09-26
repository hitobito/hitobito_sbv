module SongCountsHelper

  def song_counts_count(object)
    content = []
    content << song_counts_update_button(object, :dec) unless object.readonly?
    content << content_tag(:strong, class: 'count') do
      object.count.to_s
    end
    content << song_counts_update_button(object, :inc) unless object.readonly?
    safe_join(content)
  end

  def song_counts_update_button(action)
    icon = icon(action == :inc ? 'chevron-right' : 'chevron-left')
    link_to(icon, '#', class: "#{action}_song_count")
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
