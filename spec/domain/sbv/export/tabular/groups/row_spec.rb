# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'
describe Export::Tabular::Groups::Row do

  let(:row) { Export::Tabular::Groups::Row.new(group, []) }

  subject { row }

  context 'any group without values' do
    let(:group) { Group::Root.new }

    it 'returns blank for nil I18nEnum attributes' do
      expect(row.fetch(:klasse)).to be_blank
      expect(row.fetch(:besetzung)).to be_blank
      expect(row.fetch(:unterhaltungsmusik)).to be_blank
    end

    it 'returns nil for correspondence_language' do
      expect(row.fetch(:correspondence_language)).to be_blank
    end
  end

  describe 'Group::Verein without values' do
    let(:group) { Group::Verein.new }

    it 'returns unbekannt for nil I18nEnum attributes' do
      expect(row.fetch(:klasse)).to eq 'unbekannt'
      expect(row.fetch(:besetzung)).to eq 'unbekannt'
      expect(row.fetch(:unterhaltungsmusik)).to eq 'unbekannt'
    end

    it 'returns nil for correspondence_language' do
      expect(row.fetch(:correspondence_language)).to be_blank
    end
  end

  describe 'Group::Verein with values' do
    let(:group) { Group::Verein.new(klasse: :erste,
                                    unterhaltungsmusik: :oberstufe,
                                    besetzung: :brass_band,
                                    correspondence_language: :de) }

    it 'returns translated values for I18nEnum attributes' do
      expect(row.fetch(:klasse)).to eq '1. Klasse'
      expect(row.fetch(:besetzung)).to eq 'Brass Band'
      expect(row.fetch(:unterhaltungsmusik)).to eq 'Oberstufe'
    end

    it 'returns Deutsch for correspondence_language' do
      expect(row.fetch(:correspondence_language)).to eq 'Deutsch'
    end

    describe 'recognized_members' do
      before do
        mitglieder = Group::VereinMitglieder.create!(name: 'dummy', parent: group, deleted_at: Time.zone.now)

        10.times.each do |i|
          p = Fabricate(:person)
          Group::VereinMitglieder::Mitglied.create!(person: p, group: mitglieder)
        end
      end

      context 'when manually_counted_members is false' do
        it 'returns calculated' do
          expect(group.manually_counted_members).to eq(false)

          expect(row.fetch(:recognized_members)).to eq 10
        end
      end

      context 'when manually_counted_members is true' do
        it 'returns manually reported count if manual count is nonzero' do
          group.update(manually_counted_members: true, manual_member_count: 20)

          expect(group.manually_counted_members).to eq(true)

          expect(row.fetch(:recognized_members)).to eq 20
        end

        it 'returns automatically calulated if manual count is zero' do
          group.update(manually_counted_members: true, manual_member_count: 0)

          expect(group.manually_counted_members).to eq(true)

          expect(row.fetch(:recognized_members)).to eq 10
        end
      end
    end
  end
end
