# frozen_string_literal: true

#  Copyright (c) 2020-2024, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"
require "csv"

describe Export::Tabular::GroupParticipations::List do
  let(:list) { events(:festival).group_participations.includes(:group, :secondary_group) }
  let(:data) { described_class.csv(list) }
  let(:data_without_bom) { data.gsub(Regexp.new("^#{Export::Csv::UTF8_BOM}"), "") }
  let(:csv) { CSV.parse(data_without_bom, headers: true, col_sep: Settings.csv.separator) }

  subject { csv }

  before do
    events(:festival).group_participations.create(
      group: groups(:musikgesellschaft_aarberg),
      secondary_group: groups(:musikgesellschaft_alterswil),
      joint_participation: true,
      primary_state: "music_type_and_level_selected",
      secondary_state: "opened",
      music_style: "concert_music",
      music_type: "harmony",
      music_level: "highest"
    )

    groups(:musikgesellschaft_aarberg).roles.create(
      person: people(:conductor),
      type: Group::Verein::Conductor
    )

    events(:festival).group_participations.create(
      group: groups(:musikverband_hastdutoene),
      joint_participation: false,
      primary_state: "music_type_and_level_selected",
      music_style: "concert_music",
      music_type: "harmony",
      music_level: "first",
      parade_music: "traditional_parade"
    )
  end

  context "has assumptions" do
    it "the list has entries" do
      expect(list).to have(2).items
    end
  end

  context "has headers" do
    let(:headers) do
      [
        "Verein",
        "Spielgemeinschaft mit",
        "Sparte",
        "zusätzlich Parademusik",
        "Besetzung",
        "Klasse",
        # "1. Wunschspieltag",
        # "2. Wunschspieltag",
        # "Reglement akzeptiert",
        # "Reglement von Partnerverein akzeptiert",
        "Dirigent",
        "Kontaktperson",
        "Haupt-E-Mail",
        "Adresse",
        "PLZ",
        "Ort",
        "Land",
        "Erfasste Mitglieder"
      ]
    end

    it "translated" do
      expect(subject.headers).to match_array(headers)
    end

    it "in the right order" do
      expect(subject.headers).to eq headers
    end
  end

  context "has rows," do
    it "three rows with the above setup" do
      expect(subject.size).to_not be_zero
      expect(subject.size).to be 3
    end

    it "first the participation application of the leading group" do
      expect(csv[0]).to_not be_nil
      expect(csv[0].to_h).to include({
        "Verein" => "Musikgesellschaft Aarberg",
        "Spielgemeinschaft mit" => "Musikgesellschaft Alterswil",

        "Sparte" => "Konzertmusik",
        "zusätzlich Parademusik" => nil,
        "Besetzung" => "Harmonie",
        "Klasse" => "Höchstklasse",

        # "1. Wunschspieltag" => "Sonntag",
        # "2. Wunschspieltag" => "Samstag",

        # "Reglement akzeptiert" => "nein",
        # "Reglement von Partnerverein akzeptiert" => "ja",

        "Dirigent" => "Dieter Irigent",

        "Adresse" => "Bielertstr. 91c",
        "Kontaktperson" => nil,
        "Haupt-E-Mail" => nil,
        "Ort" => "Thiloscheid",
        "PLZ" => "6648",
        "Land" => nil,
        "Erfasste Mitglieder" => "0"
      })
    end

    it "second the participation application of the supporting group" do
      expect(csv[1]).to_not be_nil
      expect(csv[1].to_h).to include({
        "Verein" => "Musikgesellschaft Alterswil",
        "Spielgemeinschaft mit" => "Musikgesellschaft Aarberg",

        "Sparte" => "Konzertmusik",
        "zusätzlich Parademusik" => nil,
        "Besetzung" => "Harmonie",
        "Klasse" => "Höchstklasse",

        # "1. Wunschspieltag" => "Sonntag",
        # "2. Wunschspieltag" => "Samstag",

        # "Reglement akzeptiert" => "ja",
        # "Reglement von Partnerverein akzeptiert" => "nein",

        "Dirigent" => nil,

        "Adresse" => "Am Junkernkamp 2",
        "Kontaktperson" => nil,
        "Haupt-E-Mail" => "alterswil@hitobito.example.com",
        "Ort" => "Nord Boland",
        "PLZ" => "7400",
        "Land" => nil,
        "Erfasste Mitglieder" => "0"
      })
    end

    it "thirdly the application of another solitary group" do
      expect(csv[2]).to_not be_nil
      expect(csv[2].to_h).to include({
        "Verein" => "Musikverband HastDuTöne",
        "Spielgemeinschaft mit" => "",

        "Sparte" => "Konzertmusik",
        "zusätzlich Parademusik" => "traditionelle Parademusik",
        "Besetzung" => "Harmonie",
        "Klasse" => "1. Klasse",

        # "1. Wunschspieltag" => "Donnerstag",
        # "2. Wunschspieltag" => "Freitag",

        # "Reglement akzeptiert" => "ja",
        # "Reglement von Partnerverein akzeptiert" => nil,

        "Dirigent" => "Dieter Irigent",

        "Adresse" => "Friedrich-Engels-Str. 98c",
        "Kontaktperson" => nil,
        "Haupt-E-Mail" => nil,
        "Ort" => "Neu Maddoxscheid",
        "PLZ" => "7892",
        "Land" => nil,
        "Erfasste Mitglieder" => "1"
      })
    end
  end
end
