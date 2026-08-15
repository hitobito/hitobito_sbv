# frozen_string_literal: true

#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe Export::Pdf::List::People do
  subject { Export::Pdf::List.render(list_people, group) }

  let(:list_people) { group.people }
  let(:group) { groups(:musikverband_hastdutoene) }
  let(:member) { people(:member) }

  let(:pdf_text) { PDF::Inspector::Text.analyze(subject).show_text.compact.join(" ") }

  it "does not render the nickname" do
    expect(pdf_text).to_not match(/mynick/)
  end

  it "renders the name of people" do
    expect(pdf_text).to match(/My Member/)
  end

  it "renders the instrument column" do
    member.roles
      .find_by(type: Group::VereinMitglieder::Mitglied.sti_name)
      .update!(instrument: "trompete")
    pdf = Export::Pdf::List.render(group.people.reload, group)
    text = PDF::Inspector::Text.analyze(pdf).show_text.compact.join(" ")
    expect(text).to include(Role.human_attribute_name(:instrument), "Trompete")
  end

  it "creates a pdf" do
    is_expected.to start_with("%PDF-1.3")
  end

  context "when title is the group name (legacy render path)" do
    subject { Export::Pdf::List.render(list_people, group.name) }

    it "does not error and renders the instrument column" do
      member.roles
        .find_by(type: Group::VereinMitglieder::Mitglied.sti_name)
        .update!(instrument: "trompete")
      text = PDF::Inspector::Text.analyze(subject).show_text.compact.join(" ")
      expect(text).to include(Role.human_attribute_name(:instrument))
    end
  end
end
