# frozen_string_literal: true

#  Copyright (c) 2020-2021, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

# rubocop:disable Rails/HelperInstanceVariable This is part of a class, not a helper per se
module Sbv
  module StandardFormBuilder
    def group_field(attr, html_options = {})
      _attr, attr_id = assoc_and_id_attr(attr)
      hidden_field(attr_id) +
      string_field(attr, # "#{attr}_search",
                   placeholder: I18n.t('global.search.placeholder_group'),
                   name: 'group_name_search_result',
                   data: { provide: 'entity',
                           id_field: "#{object_name}_#{attr_id}",
                           url: @template.query_groups_path(html_options[:search_params]) })
    end
  end
end
# rubocop:enable Rails/HelperInstanceVariable
