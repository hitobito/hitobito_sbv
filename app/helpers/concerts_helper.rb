module ConcertsHelper

    def concerts_view_tabs(group)
      content_tag(:ul, class: 'nav nav-pills group-pills') do
        safe_join(tabs(group)) do |title, path|
          content_tag(:li,
                      link_to(title, path),
                      class: active(path) ? 'active' : nil)
        end
      end
    end

    private

    def tabs(group)
      [
        [t('concerts.actions_index.concerts'), group_concerts_path(group)],
        [t('concerts.actions_index.summary'), group_song_counts_path(group)]
      ]
    end

    def active(path)
      path == request.path
    end

end
