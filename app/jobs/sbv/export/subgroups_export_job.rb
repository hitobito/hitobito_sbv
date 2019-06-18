#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::Export::SubgroupsExportJob

  def initialize(user_id, group, options)
    super(user_id, group.id, options)
    @exporter = Export::Tabular::Groups::AddressList
  end

  private

  def entries
    super.where(type: types.collect(&:sti_name))
  end

  def types
    [
      Group::Mitgliederverband,
      Group::Regionalverband,
      Group::Verein
    ]
  end

end
