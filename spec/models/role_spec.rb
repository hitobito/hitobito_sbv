# frozen_string_literal: true

#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe Role do

  let(:role) { roles(:member) }

  it 'triggers a recalculation of the persons active_years' do
    person = role.person
    person.update_active_years # cache active_years

    expect do
      role.really_destroy!
    end.to change(person, :active_years).from(1).to(0)
  end

end
