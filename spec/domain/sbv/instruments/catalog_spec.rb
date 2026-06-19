# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe Sbv::Instruments::Catalog do
  describe ".keys" do
    it "loads instruments from config/instruments.json" do
      expect(described_class.keys).to include(
        "querfloete", "piccolo", "waldhorn", "bassklarinette", "kontrabass",
        "es_klarinette", "tenorhorn", "saxophon_alt"
      )
      expect(described_class.keys).not_to include("floete", "horn", "saxophon")
    end
  end

  describe ".label_for" do
    it "returns localized labels" do
      expect(described_class.label_for("saxophon_tenor", locale: :de)).to eq "Tenor-Saxophon"
      expect(described_class.label_for("saxophon_tenor", locale: :fr)).to eq "Saxophone ténor"
    end
  end

  describe ".map" do
    it "maps enum keys" do
      expect(described_class.map("saxophon_bass")).to eq "saxophon_bass"
    end

    it "maps legacy aliases" do
      expect(described_class.map("saxophon")).to eq "saxophon_alt"
      expect(described_class.map("floete")).to eq "querfloete"
      expect(described_class.map("horn")).to eq "waldhorn"
      expect(described_class.map("Flöte")).to eq "querfloete"
    end

    it "maps translated labels" do
      expect(described_class.map("Sopran-Saxophon")).to eq "saxophon_sopran"
    end
  end

  describe ".register_i18n!" do
    it "registers instrument labels for I18n" do
      described_class.register_i18n!

      expect(I18n.t("activerecord.attributes.role.instruments.saxophon_alt", locale: :de))
        .to eq "Alt-Saxophon"
    end
  end
end
