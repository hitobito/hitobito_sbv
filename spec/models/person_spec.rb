# frozen_string_literal: true

#  Copyright (c) 2012-2024, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe Person do
  include ActiveSupport::Testing::TimeHelpers

  subject { people(:member) }

  # original validations, commented for https://github.com/hitobito/hitobito_sbv/issues/125
  # revert commit later to restore original behaviour
  #
  # %w(first_name last_name birthday).each do |attr|

  %w[first_name last_name].each do |attr|
    it "validates presence of #{attr}" do
      subject.update_attribute(attr, "")
      translated_attr = Person.human_attribute_name(attr)

      is_expected.to_not be_valid
      expect(subject.errors.full_messages)
        .to include("#{translated_attr} muss ausgefüllt werden")
    end
  end

  context "active_years" do
    subject { people(:conductor) }

    def create_role(role_class, years: 10, start_date: false, end_date: false)
      start_year = 2005
      start_on = begin
        start_date.presence || Date.current.change(year: start_year)
      rescue Date::Error
        Date.current.change(day: 25, year: start_year)
      end

      end_on = if end_date == false
        begin
          Date.current.change(year: start_year + years)
        rescue Date::Error
          Date.current.change(day: 25, year: start_year + years)
        end
      else # could be a date-string or nil to leave it active
        end_date
      end

      Fabricate(
        role_class.name.to_sym,
        person: subject,
        group: groups(:mitglieder_hastdutoene),
        start_on: start_on,
        end_on: end_on
      )
    end

    it "has assumptions" do
      expect do
        subject.update_active_years
      end.to change(subject, :active_years).from(nil).to(0)

      roles = subject.roles.map { |r| [r.type, r.group_id] }

      expect(roles).to match_array [
        ["Group::Verein::Conductor", 678378847]
      ]
    end

    it "is contained in a module" do
      is_expected.to be_a Person::ActiveYears
    end

    it "considers Mitglied" do
      create_role(Group::VereinMitglieder::Mitglied, years: 10)
      subject.update_active_years

      expect(subject.active_years).to be 11 # even partial years count, so 10 years later cover 11 years
    end

    it "considers historic Mitglied roles" do
      # Create the role without validation because it's technically not allowed,
      # but we create such roles anyway in import.rake
      Fabricate.build(
        :"Role::MitgliederMitglied",
        person: subject,
        group: groups(:mitglieder_hastdutoene),
        start_on: Date.current.change(year: 2005, day: 25),
        end_on: Date.current.change(year: 2012)
      ).save(validate: false)

      subject.update_active_years

      expect(subject.active_years).to be 8 # even partial years count, so 7 years later cover 8 years
    end

    it "does not consider PassivMitglied" do
      create_role(Group::VereinMitglieder::Passivmitglied, years: 10)
      subject.update_active_years

      expect(subject.active_years).to be 0
    end

    it "does not consider historic PassivMitglied roles" do
      # Create the role without validation because it's technically not allowed,
      # but we create such roles anyway in import.rake
      Fabricate.build(
        :"Role::MitgliederPassivmitglied",
        person: subject,
        group: groups(:mitglieder_hastdutoene),
        start_on: Date.current.change(year: 2005, day: 25),
        end_on: Date.current.change(year: 2015, day: 25)
      ).save(validate: false)

      subject.update_active_years

      expect(subject.active_years).to be 0
    end

    it "does not consider Adressverwaltung" do
      create_role(Group::VereinMitglieder::Adressverwaltung, years: 10)
      subject.update_active_years

      expect(subject.active_years).to be 0
    end

    it "does not consider Ehrenmitglied" do
      create_role(Group::VereinMitglieder::Ehrenmitglied, years: 10)
      subject.update_active_years

      expect(subject.active_years).to be 0
    end

    context "assuming it is the summer of 2020" do
      before { travel_to Date.new(2020, 7, 31) }

      it "counts completed years in the past" do
        expect do
          create_role(Group::VereinMitglieder::Mitglied, start_date: "2018-12-01", end_date: nil)
          subject.update_active_years
        end.to change(subject, :active_years).to(2)
      end

      it "counts only years with membership" do
        expect do
          create_role(Group::VereinMitglieder::Mitglied, start_date: "2018-02-01", end_date: "2018-04-30")
          create_role(Group::VereinMitglieder::Mitglied, start_date: "2018-12-01", end_date: "2019-07-31")
          subject.update_active_years
        end.to change(subject, :active_years).to(2)
      end

      it "counts multiple durations in one year only once" do
        expect do
          create_role(Group::VereinMitglieder::Mitglied, start_date: "2018-02-01", end_date: "2018-04-30")
          create_role(Group::VereinMitglieder::Mitglied, start_date: "2019-01-01", end_date: nil)
          subject.update_active_years
        end.to change(subject, :active_years).to(2)
      end

      it "counts years which have an short interruption fully" do
        expect do
          create_role(Group::VereinMitglieder::Mitglied, start_date: "2018-02-01", end_date: "2018-04-30")
          create_role(Group::VereinMitglieder::Mitglied, start_date: "2019-01-01", end_date: "2019-10-31")
          create_role(Group::VereinMitglieder::Mitglied, start_date: "2020-01-01", end_date: nil)
          subject.update_active_years
        end.to change(subject, :active_years).to(2)
      end

      it "does not count completely omitted years" do
        expect do
          create_role(Group::VereinMitglieder::Mitglied, start_date: "2018-02-01", end_date: "2018-04-30")
          create_role(Group::VereinMitglieder::Mitglied, start_date: "2020-01-01", end_date: nil)

          subject.update_active_years
        end.to change(subject, :active_years).to(1)
      end
    end

    it "handles active_years not being cached" do
      travel_to("2020-03-16") do
        expect(subject.roles.with_inactive.where(type: "Group::VereinMitglieder::Mitglied").count).to eq 0
        expect(subject.active_years).to be_nil

        expect(subject.prognostic_active_years).to eq 0

        Fabricate(
          Group::VereinMitglieder::Mitglied.name.to_sym,
          person: subject,
          group: groups(:mitglieder_hastdutoene),
          start_on: Date.current.change(year: 2010),
          end_on: nil # active Role
        )

        expect(subject.roles.where(type: "Group::VereinMitglieder::Mitglied").count).to eq 1
        expect(subject.active_years).to eq 10

        # simulate data not being present
        subject.active_years = nil
        subject.active_role = nil
        expect(subject.active_years).to be_nil

        expect(subject.prognostic_active_years).to eq 11
      end
    end
  end
end
