# frozen_string_literal: true

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Dropdown
  class SongCounts < Base

    attr_reader :params

    def initialize(template, params, type)
      super(template, translate(:button), type)
      @params = params
    end

    def export
      csv_links
      xlsx_links
      self
    end

    private

    def csv_links
      add_item(translate(:csv), export_path(:csv, controller: :song_counts), **item_options)
    end

    def xlsx_links
      add_item(translate(:xlsx), export_path(:xlsx, controller: :song_counts), **item_options)
    end

    def item_options
      { data: { checkable: true } }
    end

    def export_path(format, options = {})
      params.merge(options).merge(format: format)
    end
  end
end
