#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe Export::Tabular::Groups::List do
  let(:subject) { Export::Tabular::Groups::List.new([groups(:hauptgruppe_1)]) }

  it "does includes computed recognized_members attribute" do
    expect(subject.attributes).to include(:recognized_members)
  end
end
