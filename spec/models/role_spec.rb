# frozen_string_literal: true

#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe Role do

  let(:role) { roles(:member) }

  it "validates presence of created_at if deleted_at is present" do
    role.update(
      created_at: nil,
      deleted_at: Time.zone.now
    )

    expect(role).not_to be_valid
    expect(role.errors.full_messages).
      to include('Eintritt muss ausgefüllt werden')
  end

  it "validate created_at is earlier than today" do
    role.update_attribute(:created_at, 1.day.from_now)

    expect(role).not_to be_valid
    expect(role.errors.full_messages).
      to include('Eintritt kann nicht später als heute sein')
  end

  it "validate created_at can be equal with today" do
    role.update_attribute(:created_at, Time.zone.today)

    expect(role).to be_valid
  end

  it "validate created_at is earlier than deleted_at" do
    role.update_attribute(:created_at, 1.day.ago)
    role.update_attribute(:deleted_at, 3.day.ago)

    expect(role).not_to be_valid
    expect(role.errors.full_messages).
      to include('Eintritt muss vor oder am selben Tag wie der Austritt sein')
  end

  it "validate created_at can be equal with deleted_at" do
    role.update_attribute(:created_at, Time.zone.now)
    role.update_attribute(:deleted_at, Time.zone.now)

    expect(role).to be_valid
  end

  it 'triggers a recalculation of the persons active_years' do
    person = role.person
    person.update_active_years # cache active_years

    expect do
      role.really_destroy!
    end.to change(person, :active_years).from(1).to(0)
  end

end
