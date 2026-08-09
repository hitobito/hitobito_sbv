# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe Export::LabelsJob do
  let(:user) { people(:admin) }
  let(:group) { groups(:musikverband_hastdutoene) }
  let(:person) { people(:member) }
  let(:filename) { AsyncDownloadFile.create_name("people_export", user.id) }

  before do
    person.roles.find_by(group: group).update!(instrument: "trompete")
  end

  subject do
    Export::LabelsJob.new(
      :pdf,
      user.id,
      [person.id],
      group.id,
      filename: filename
    )
  end

  it "renders a pdf with the instrument column" do
    subject.perform
    pdf = AsyncDownloadFile.from_filename(filename, :pdf).read
    text = PDF::Inspector::Text.analyze(pdf).show_text.compact.join(" ")
    expect(text).to include(Role.human_attribute_name(:instrument), "Trompete")
    expect(pdf).to start_with("%PDF-1.3")
  end
end
