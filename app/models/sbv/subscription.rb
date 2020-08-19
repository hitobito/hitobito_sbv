# frozen_string_literal: true

#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.
#

module Sbv::Subscription
  extend ActiveSupport::Concern

  def possible_groups
    patched_children = mailing_list.group.children.without_deleted.pluck(:id)

    Group.where(id: (patched_children | super.map(&:id)))
  end
end
