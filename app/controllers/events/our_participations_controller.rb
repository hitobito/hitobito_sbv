#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class Events::OurParticipationsController < ListController
  self.nesting = Group

  skip_authorize_resource
  skip_authorization_check

  before_action :list_festivals

  private_class_method

  def self.model_class
    Event::GroupParticipation
  end

  private

  def list_entries
    model_class.where(group_id: parent.id)
  end

  def list_festivals
    @festivals ||= Event::Festival.participatable(parent)
  end

  def authorize_class
    true
  end

  # def authorize_class
  #   authorize! :manage_festival_participation, parent
  # end
end
