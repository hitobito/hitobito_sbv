# encoding: utf-8

#  Copyright (c) 2012-2019, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'


describe GroupAbility do

  subject { ability }
  let(:role) { Fabricate(Group::Root::Admin.name.to_sym, group: groups(:hauptgruppe_1)) }
  let(:ability) { Ability.new(role.person.reload) }
  let(:group) { role.group }

  it { is_expected.to be_able_to(:'index_event/festivals', group) }
end
