#  Copyright (c) 2019-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class Events::OurParticipationsController < ListController
  self.nesting = Group

  before_action :list_festivals

  private_class_method

  def self.model_class
    Event::GroupParticipation
  end

  private

  def list_entries
    our_id = parent.layer_group_id

    model_class.where('group_id = ? OR secondary_group_id = ?', our_id, our_id)
  end

  def list_festivals
    @festivals ||= Event::Festival.participatable(parent.layer_group)
  end

  def authorize_class
    authorize! :manage_festival_application, parent
  end
end
