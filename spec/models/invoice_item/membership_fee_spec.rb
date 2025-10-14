#  Copyright (c) 2023, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe InvoiceItem::MembershipFee do
  let(:invoice_item) { InvoiceItem::MembershipFee.new(attrs) }
  let(:attrs) {
    {name: "Membership Fee",
     count: 1,
     unit_cost: 0,
     dynamic_cost_parameters: {amount: 10,
                               recipient_id: recipient&.id,
                               cutoff_date: 10.days.from_now.to_date.to_s}}
  }
  let(:vorstand) { groups(:vorstand_mg_aarberg) }
  let(:verein) { vorstand.layer_group }

  describe "#dynamic_cost" do
    let(:recipient) {}

    it "returns nil if recipient_id is blank" do
      expect(invoice_item.dynamic_cost_parameters[:recipient_id]).to be_blank
      expect(invoice_item.dynamic_cost).to be_nil
    end

    context "with vorstands kassier as recipient" do
      let(:recipient) {
        Fabricate(Group::VereinVorstand::Kassier.sti_name.to_sym, group: vorstand).person
      }

      context "using manually_counted_members" do
        before {
          vorstand.layer_group.update(manually_counted_members: true, manual_member_count: 20)
        }

        it "returns correct amount" do
          expect(invoice_item.dynamic_cost).to eq(200) # 10 * 20
        end
      end

      context "using automatic member count" do
        let!(:member_groups) {
          (1..3).map {
         # rubocop:todo Layout/IndentationWidth
         Fabricate(Group::VereinMitglieder.sti_name.to_sym, parent: verein)
            # rubocop:enable Layout/IndentationWidth
          }
        }
        let!(:member_roles) {
          member_groups.flat_map { |g|
                                (1..20).map { # rubocop:todo Layout/IndentationWidth
         # rubocop:todo Layout/IndentationWidth
         Fabricate(Group::VereinMitglieder::Mitglied.sti_name.to_sym, group: g)
                                  # rubocop:enable Layout/IndentationWidth
                                }
          }
        }

        it "returns correct amount" do
          expect(invoice_item.dynamic_cost).to eq(600) # 3 * 20 * 10
        end

        it "excludes members with roles end_on before cutoff_date" do
          member_roles.sample(5).each { |r| r.update(end_on: 5.days.from_now.to_s.to_date) }
          expect(invoice_item.dynamic_cost).to eq(550) # (3 * 20 - 5) * 10
        end
      end
    end

    context "with vorstands praesident as recipient" do
      let(:recipient) {
        Fabricate(Group::VereinVorstand::Praesident.sti_name.to_sym, group: vorstand).person
      }

      context "using manually_counted_members" do
        before {
          vorstand.layer_group.update(manually_counted_members: true, manual_member_count: 20)
        }

        it "returns correct amount" do
          expect(invoice_item.dynamic_cost).to eq(200) # 10 * 20
        end
      end

      context "using automatic member count" do
        let!(:member_groups) {
          (1..3).map {
         # rubocop:todo Layout/IndentationWidth
         Fabricate(Group::VereinMitglieder.sti_name.to_sym, parent: verein)
            # rubocop:enable Layout/IndentationWidth
          }
        }
        let!(:member_roles) {
          member_groups.flat_map { |g|
                                (1..20).map { # rubocop:todo Layout/IndentationWidth
         # rubocop:todo Layout/IndentationWidth
         Fabricate(Group::VereinMitglieder::Mitglied.sti_name.to_sym, group: g)
                                  # rubocop:enable Layout/IndentationWidth
                                }
          }
        }

        it "returns correct amount" do
          expect(invoice_item.dynamic_cost).to eq(600) # 3 * 20 * 10
        end

        it "excludes members with roles end_on before cutoff_date" do
          member_roles.sample(5).each { |r| r.update(end_on: 5.days.from_now.to_s.to_date) }
          expect(invoice_item.dynamic_cost).to eq(550) # (3 * 20 - 5) * 10
        end
      end
    end

    context "with vereins admin as recipient" do
      let(:recipient) { Fabricate(Group::Verein::Admin.sti_name.to_sym, group: verein).person }

      context "using manually_counted_members" do
        before {
          vorstand.layer_group.update(manually_counted_members: true, manual_member_count: 20)
        }

        it "returns correct amount" do
          expect(invoice_item.dynamic_cost).to eq(200) # 10 * 20
        end
      end

      context "using automatic member count" do
        let!(:member_groups) {
          (1..3).map {
         # rubocop:todo Layout/IndentationWidth
         Fabricate(Group::VereinMitglieder.sti_name.to_sym, parent: verein)
            # rubocop:enable Layout/IndentationWidth
          }
        }
        let!(:member_roles) {
          member_groups.flat_map { |g|
                                (1..20).map { # rubocop:todo Layout/IndentationWidth
         # rubocop:todo Layout/IndentationWidth
         Fabricate(Group::VereinMitglieder::Mitglied.sti_name.to_sym, group: g)
                                  # rubocop:enable Layout/IndentationWidth
                                }
          }
        }

        it "returns correct amount" do
          expect(invoice_item.dynamic_cost).to eq(600) # 3 * 20 * 10
        end

        it "excludes members with roles end_on before cutoff_date" do
          member_roles.sample(5).each { |r| r.update(end_on: 5.days.from_now.to_s.to_date) }
          expect(invoice_item.dynamic_cost).to eq(550) # (3 * 20 - 5) * 10
        end
      end
    end
  end
end
