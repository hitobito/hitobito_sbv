#  Copyright (c) 2012-2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe Group::Verein do

  it '.hidden creates hidden verein in root group without children' do
    hidden = described_class.hidden
    expect(hidden).to be_deleted
    expect(hidden.reload).to have(0).children
  end

  it '.hidden may have additional deleted children ' do
    hidden = described_class.hidden
    Group::VereinMitglieder.create!(name: 'dummy', parent: hidden, deleted_at: Time.zone.now)
    expect(hidden).to be_deleted
    expect(hidden.reload).to have(1).children
    expect(hidden.children.first).to be_deleted
  end

end
