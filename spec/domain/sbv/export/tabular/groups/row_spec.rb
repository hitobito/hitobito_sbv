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
  end
end
