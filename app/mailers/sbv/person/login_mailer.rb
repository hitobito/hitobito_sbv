# frozen_string_literal: true
#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.


module Sbv::Person::LoginMailer

  private

  def placeholder_dachverband
    if @recipient.primary_group
      @recipient.primary_group.self_and_ancestors.find_by(type: Group::Root.sti_name).to_s
    end
  end

end
