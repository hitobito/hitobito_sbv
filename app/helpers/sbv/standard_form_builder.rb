# frozen_string_literal: true

#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv
  module StandardFormBuilder
    def group_field(attr, _html_options = {})
      attr, attr_id = assoc_and_id_attr(attr)
      hidden_field(attr_id) +
      string_field(attr,
                   placeholder: I18n.t('global.search.placeholder_group'),
                   data: { provide: 'entity',
                           id_field: "#{object_name}_#{attr_id}",
                           url: @template.query_groups_path })
    end
  end
end
