#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe Event::Festival do
  it 'knows which event are participatable' do
    expect(described_class.participatable).to be_an Array
    pending
  end

  it 'knows which groups have already applied' do
    expect(described_class.participation_by(nil)).to be_an Array
    pending
  end
end
