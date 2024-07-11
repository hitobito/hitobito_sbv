# frozen_string_literal: true

#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Dropdown
  class GroupParticipations < Base
    attr_reader :params

    def initialize(template, params, type)
      super(template, translate(:button), type)
      @params = params # rubocop:disable Rails/HelperInstanceVariable
    end

    def export
      csv_links
      xlsx_links
      self
    end

    private

    def csv_links
      add_item(translate(:csv), export_path(:csv), **item_options)
    end

    def xlsx_links
      add_item(translate(:xlsx), export_path(:xlsx), **item_options)
    end

    def item_options
      {data: {checkable: true}}
    end

    def export_path(format)
      template.group_event_group_participations_path(event_id: params[:id], format: format)
    end
  end
end
