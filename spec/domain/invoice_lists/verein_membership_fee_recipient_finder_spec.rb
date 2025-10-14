#  Copyright (c) 2023, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe InvoiceLists::VereinMembershipFeeRecipientFinder do
  let(:verein) { Fabricate(Group::Verein.sti_name.to_sym, parent: groups(:alt_thiesdorf_30)) }
  let(:vorstand) { Group::VereinVorstand.find_by(parent: verein) }

  describe "#find_recipient" do
    subject { InvoiceLists::VereinMembershipFeeRecipientFinder.find_recipient(verein.id) }

    context "with only admin role" do
      let!(:admin_role) { Fabricate(Group::Verein::Admin.sti_name.to_sym, group: verein) }

      it "finds admin role" do
        expect(subject).to eq(admin_role)
      end
    end

    context "with verein vorstand" do
      context "with only kassier role" do
        let!(:kassier_role) {
          Fabricate(Group::VereinVorstand::Kassier.sti_name.to_sym, group: vorstand)
        }

        it "finds kassier role" do
          expect(subject).to eq(kassier_role)
        end
      end

      context "with only praesident role" do
        let!(:praesident_role) {
          Fabricate(Group::VereinVorstand::Praesident.sti_name.to_sym, group: vorstand)
        }

        it "finds praesident role" do
          expect(subject).to eq(praesident_role)
        end
      end

      context "with admin, kassier and praesident role" do
        let!(:admin_role) { Fabricate(Group::Verein::Admin.sti_name.to_sym, group: verein) }
        let!(:kassier_role) {
          Fabricate(Group::VereinVorstand::Kassier.sti_name.to_sym, group: vorstand)
        }
        let!(:praesident_role) {
          Fabricate(Group::VereinVorstand::Praesident.sti_name.to_sym, group: vorstand)
        }

        it "finds kassier role" do
          expect(subject).to eq(kassier_role)
        end
      end

      context "with kassier and praesident role" do
        let!(:kassier_role) {
          Fabricate(Group::VereinVorstand::Kassier.sti_name.to_sym, group: vorstand)
        }
        let!(:praesident_role) {
          Fabricate(Group::VereinVorstand::Praesident.sti_name.to_sym, group: vorstand)
        }

        it "finds kassier role" do
          expect(subject).to eq(kassier_role)
        end
      end

      context "with admin and kassier role" do
        let!(:admin_role) { Fabricate(Group::Verein::Admin.sti_name.to_sym, group: verein) }
        let!(:kassier_role) {
          Fabricate(Group::VereinVorstand::Kassier.sti_name.to_sym, group: vorstand)
        }

        it "finds kassier role" do
          expect(subject).to eq(kassier_role)
        end
      end

      context "with admin and praesident role" do
        let!(:admin_role) { Fabricate(Group::Verein::Admin.sti_name.to_sym, group: verein) }
        let!(:praesident_role) {
          Fabricate(Group::VereinVorstand::Praesident.sti_name.to_sym, group: vorstand)
        }

        it "finds praesident role" do
          expect(subject).to eq(praesident_role)
        end
      end
    end
  end

  describe "find_verein" do
    subject { InvoiceLists::VereinMembershipFeeRecipientFinder.find_verein(recipient.id) }

    let!(:admin_role) { Fabricate(Group::Verein::Admin.sti_name.to_sym, group: verein) }
    let!(:kassier_role) {
      Fabricate(Group::VereinVorstand::Kassier.sti_name.to_sym, group: vorstand)
    }
    let!(:praesident_role) {
      Fabricate(Group::VereinVorstand::Praesident.sti_name.to_sym, group: vorstand)
    }

    context "for admin role" do
      let(:recipient) { admin_role.person }

      it "finds verein" do
        expect(subject).to eq(verein)
      end
    end

    context "for kassier role" do
      let(:recipient) { kassier_role.person }

      it "finds verein" do
        expect(subject).to eq(verein)
      end
    end

    context "for praesident role" do
      let(:recipient) { praesident_role.person }

      it "finds verein" do
        expect(subject).to eq(verein)
      end
    end
  end
end
