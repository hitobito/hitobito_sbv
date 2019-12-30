module GroupParticipationsHelper
  def music_styles_selection
    Event::GroupParticipation::MUSIC_CLASSIFICATIONS.map do |h|
      music_i18n_option(:music_style, h[:style])
    end
  end

  def music_types_selection_for(music_style)
    music_types_for(music_style).keys.map { |v| music_i18n_option(:music_type, v) }
  end

  def music_level_selections_for(music_style)
    music_types_for(music_style).map do |type, levels|
      values = levels.map { |level| music_i18n_option(:music_level, level) }

      content_tag(:div, hidden: true, class: type) { options_for_select(values || []) }
    end.join.html_safe
  end

  def music_types_for(music_style)
    Event::GroupParticipation::MUSIC_CLASSIFICATIONS.find { |h| h[:style] == music_style }[:types]
  end

  def music_i18n_option(kind, value)
    [music_i18n(kind, value), value]
  end

  def music_i18n(kind, value)
    model_key = Event::GroupParticipation.name.underscore
    t("activerecord.attributes.#{model_key}.#{kind.to_s.pluralize}.#{value}")
  end
end
