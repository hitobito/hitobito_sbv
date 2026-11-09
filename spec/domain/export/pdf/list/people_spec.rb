# frozen_string_literal: true

#  Copyright (c) 2020-2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe Export::Pdf::List::People do
  subject { Export::Pdf::List.render(people, group) }

  let(:people) { group.people }
  let(:group) { groups(:musikverband_hastdutoene) }

  let(:pdf_text) { PDF::Inspector::Text.analyze(subject).show_text.compact.join(" ") }

  it "does not render the nickname" do
    expect(pdf_text).to_not match(/mynick/)
  end

  it "renders the name of people" do
    expect(pdf_text).to match(/My Member/)
  end

  it "renders the home and mobile phone numbers" do
    person = people.first
    %w[landline mobile work].each_with_index do |key, i|
      category = Fabricate(:contact_account_category, key:,
        contact_account_type: "PhoneNumber", contactable_type: "Person")
      Fabricate(:phone_number, contactable: person, category:, number: "+41 79 000 00 0#{i}")
    end

    expect(pdf_text).to include("+41 79 000 00 00", "+41 79 000 00 01")
    expect(pdf_text).not_to include("+41 79 000 00 02")
  end

  it "creates a pdf" do
    is_expected.to start_with("%PDF-1.3")
  end
end
