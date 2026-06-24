# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::Export::LabelsJob
  def data
    if @format == :pdf && @options[:label_format_id].blank?
      Export::Pdf::List.render(people, group)
    else
      super
    end
  end
end
