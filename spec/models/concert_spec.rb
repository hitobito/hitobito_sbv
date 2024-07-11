#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe Concert do
  it "can infer verband-relations" do
    concert = Concert.new(verein: groups(:musikgesellschaft_alterswil), year: 2018)

    expect(concert).to be_respond_to(:infer_verband_ids)
    expect do
      concert.infer_verband_ids
    end.to change(concert, :regionalverband).from(nil).to(groups(:alt_thiesdorf_30))
      .and change(concert, :mitgliederverband).from(nil).to(groups(:societe_cantonale_des_musiques_fribourgeoises_freiburger_kantonal_musikverband_24))
  end

  context "before validation" do
    it "sets verband ids for verein nested under regionalverband " do
      concert = Concert.create!(verein: groups(:musikgesellschaft_alterswil), year: 2018)

      expect(concert.regionalverband).to eq groups(:alt_thiesdorf_30)
      expect(concert.mitgliederverband).to eq groups(:societe_cantonale_des_musiques_fribourgeoises_freiburger_kantonal_musikverband_24)
    end

    it "sets mitgliederverband for verein nested under mitgliederverband" do
      verein = Group::Verein.create!(name: "group", parent: groups(:bernischer_kantonal_musikverband))
      concert = Concert.create!(verein: verein, year: 2018)

      expect(concert.regionalverband).to be_nil
      expect(concert.mitgliederverband).to eq groups(:bernischer_kantonal_musikverband)
    end

    it "does not set verband ids for verein nested under root" do
      verein = Group::Verein.create!(name: "group", parent: groups(:hauptgruppe_1))
      concert = Concert.create!(verein: verein, year: 2018)

      expect(concert.regionalverband).to be_nil
      expect(concert.mitgliederverband).to be_nil
    end

    it "sets name if nothing is given" do
      concert = Concert.create!(verein: groups(:musikgesellschaft_alterswil), year: 2018)

      expect(concert.name).to eq "Aufführung ohne Datum"
    end

    it "removes empty song counts" do
      song_counts = [SongCount.new(count: 0, song: songs(:papa), year: 2018),
        SongCount.new(count: 0, song: songs(:son), year: 2018),
        SongCount.new(count: 1, song: songs(:girl), year: 2018)]

      concert = Concert.create!(verein: groups(:musikgesellschaft_alterswil),
        year: 2018,
        song_counts: song_counts)

      expect(concert.song_counts.count).to be 1
      expect(concert.song_counts.first.song).to eq(songs(:girl))
    end
  end

  context "validations" do
    it "name has a maximum length" do
      subject.name = ("La" * 130) + "TrumpetMan"
      expect(subject.name.length).to be > 255

      expect(subject).to_not be_valid
      expect(subject.errors).to have_key(:name)
    end
  end

  context "soft-deletion" do
    subject(:concert) { concerts(:third_concert) }

    let(:verein) { concert.verein }

    it "is supported" do
      expect(concert.class.ancestors).to include(Paranoia)

      expect do
        concert.destroy!
      end.to change { Concert.without_deleted.count }.by(-1)

      expect(concert.reload.deleted_at).to_not be_nil
    end

    it "by association" do
      verein.children.each(&:destroy!) # ensure group can be deleted

      expect do
        verein.destroy!
      end.to change { Concert.without_deleted.count }.by(-1)
    end
  end

  context "reason" do
    subject(:concert) { concerts(:six_concert) }

    it "can be joint_play" do
      concert.reason = "joint_play"

      is_expected.to be_joint_play
      expect(concert.reason).to eq "joint_play"
      expect(concert.reason_label).to eq reason("joint_play")

      is_expected.to be_valid
    end

    it "can be not_playable" do
      concert.reason = "not_playable"

      is_expected.to be_not_playable
      expect(concert.reason).to eq "not_playable"
      expect(concert.reason_label).to eq reason("not_playable")

      is_expected.to be_valid
    end

    it "can be otherwise_billed" do
      concert.reason = "otherwise_billed"

      is_expected.to be_otherwise_billed
      expect(concert.reason).to eq "otherwise_billed"
      expect(concert.reason_label).to eq reason("otherwise_billed")

      is_expected.to be_valid
    end

    it "cannot be something else" do
      expect do
        concert.reason = "something else"
      end.to change(concert, :valid?).from(true).to(false)
    end

    it "is played by default" do
      new_concert = described_class.new

      expect(new_concert).to be_played
      expect(new_concert.reason).to be_nil
      expect(new_concert.reason_label).to eq reason("_nil")
    end

    context "comes with scopes" do # whose concrete results depend on fixtures. sorry.
      it "to select played/normale concerts" do
        expect(described_class).to respond_to(:played)
        expect(described_class.played.count).to be 6
      end

      it "to select not played/placeholder concerts" do
        expect(described_class).to respond_to(:not_played)
        expect(described_class.not_played.count).to be 1
      end
    end

    def reason(key)
      I18n.t(key, scope: "activerecord.attributes.concert.reasons")
    end
  end
end
