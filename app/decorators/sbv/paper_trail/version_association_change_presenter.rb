# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::PaperTrail::VersionAssociationChangePresenter
  private

  def changeset_list
    presenter = PaperTrail::VersionChangesetPresenter.new(version, h)

    rendered_changes = changeset.filter_map do |attr, (from, to)|
      presenter.attribute_change(attr, from, to).presence
    end

    h.safe_join(rendered_changes, ", ")
  end
end
