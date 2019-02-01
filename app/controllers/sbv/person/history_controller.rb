#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::Person::HistoryController
  def entry
    super
  rescue ActiveRecord::RecordNotFound => e
    if @group.is_a? Group::Root
      @person = Person.where(primary_group_id: nil).find(params[:id])
    else
      raise e
    end
  end
end
