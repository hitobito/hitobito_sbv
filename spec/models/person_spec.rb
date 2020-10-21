# frozen_string_literal: true

#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe Person do
  include ActiveSupport::Testing::TimeHelpers

  subject { people(:member) }

  %w(first_name last_name birthday).each do |attr|
    it "validates presence of #{attr}" do
      subject.update_attribute(attr, '')
      translated_attr = Person.human_attribute_name(attr)

      is_expected.to_not be_valid
      expect(subject.errors.full_messages).
        to include("#{translated_attr} muss ausgefüllt werden")
    end
  end

  context 'active_years' do
    subject { people(:conductor) }

    def create_role(role_class, years: 10)
      start_year = 2005
      end_year = start_year + years

      Fabricate(
        role_class.name.to_sym,
        person: subject,
        group: groups(:mitglieder_hastdutoene),
        created_at: Date.current.change(year: start_year),
        deleted_at: Date.current.change(year: end_year)
      )
    end

    it 'has assumptions' do
      expect do
        subject.update_active_years
      end.to change(subject, :active_years).from(nil).to(0)

      roles = subject.roles.map { |r| [r.type, r.group_id] }

      expect(roles).to match_array [
        ['Group::Verein::Conductor', 678378847]
      ]
    end

    it 'is contained in a module' do
      is_expected.to be_a Person::ActiveYears
    end

    it 'considers Mitglied' do
      create_role(Group::VereinMitglieder::Mitglied, years: 10)
      subject.update_active_years

      expect(subject.active_years).to be 10
    end

    it 'does not consider PassivMitglied' do
      create_role(Group::VereinMitglieder::Passivmitglied, years: 10)
      subject.update_active_years

      expect(subject.active_years).to be 0
    end

    it 'does not consider Adressverwaltung' do
      create_role(Group::VereinMitglieder::Adressverwaltung, years: 10)
      subject.update_active_years

      expect(subject.active_years).to be 0
    end

    it 'does not consider Ehrenmitglied' do
      create_role(Group::VereinMitglieder::Ehrenmitglied, years: 10)
      subject.update_active_years

      expect(subject.active_years).to be 0
    end

    it 'handles active_years not being cached' do
      travel_to('2020-03-16') do
        expect(subject.roles.with_deleted.where(type: 'Group::VereinMitglieder::Mitglied').count).to eq 0
        expect(subject.active_years).to be_nil

        expect(subject.prognostic_active_years).to eq 0

        Fabricate(
          Group::VereinMitglieder::Mitglied.name.to_sym,
          person: subject,
          group: groups(:mitglieder_hastdutoene),
          created_at: Date.current.change(year: 2010),
          deleted_at: nil # active Role
        )


        expect(subject.roles.without_deleted.where(type: 'Group::VereinMitglieder::Mitglied').count).to eq 1
        expect(subject.active_years).to eq 11

        # simulate data not being present
        subject.active_years = nil
        subject.active_role = nil
        expect(subject.active_years).to be_nil

        expect(subject.prognostic_active_years).to eq 12
      end
    end
  end

end
