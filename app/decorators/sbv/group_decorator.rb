# frozen_string_literal: true

#  Copyright (c) 2012-2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::GroupDecorator
  def link_with_layer
    (model.parent_id == Group::Verein.hidden.id) ? model.name : super
  end
end
