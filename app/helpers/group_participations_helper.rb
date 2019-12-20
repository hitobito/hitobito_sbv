module GroupParticipationsHelper
  def music_styles_selection
    Event::GroupParticipation::MUSIC_CLASSIFICATIONS.map { |h| h[:style] }
  end

  def music_types_selection_for(music_style)
    music_types_for(music_style).keys
  end

  def music_level_selections_for(music_style)
    music_types_for(music_style).map do |type, levels|
      content_tag(:div, hidden: true, class: type) { options_for_select(levels || []) }
    end.join.html_safe
  end

  def music_types_for(music_style)
    Event::GroupParticipation::MUSIC_CLASSIFICATIONS.find { |h| h[:style] == music_style }[:types]
  end
end
