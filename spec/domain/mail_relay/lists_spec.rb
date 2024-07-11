#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require "spec_helper"

describe MailRelay::Lists do
  let(:message) do
    mail = Mail.new(File.read(Rails.root.join("spec", "fixtures", "email", "regular.eml")))
    mail.header["X-Original-To"] = "dummy"
    mail.from = people(:admin).email
    mail
  end

  let(:relay) { MailRelay::Lists.new(message) }
  let(:group) { groups(:kontakte_5) }

  before { group.mailing_lists.create!(name: "dummy", mail_name: "dummy") }

  context "#prepare_not_allowed_message" do
    subject { relay.send(:prepare_not_allowed_message).from.first.split("@").last }

    it "#mail_domain falls back to settings" do
      expect(subject).to eq Settings.email.list_domain
    end

    it "#mail_domain might read hostname from group" do
      group.update!(hostname: "group.example.com")
      expect(subject).to eq "group.example.com"
    end

    it "#mail_domain might read hostname from hierarchy" do
      group.parent.update!(hostname: "parent.example.com")
      expect(subject).to eq "parent.example.com"
    end
  end

  context "#envelope_sender" do
    subject { relay.send(:envelope_sender) }

    it "reads hostname from Settings" do
      expect(subject).to eq "dummy-bounces+admin=hitobito.example.com@localhost"
    end

    it "reads hostname from group" do
      group.update!(hostname: "group.example.com")
      expect(subject).to eq "dummy-bounces+admin=hitobito.example.com@group.example.com"
    end

    it "reads hostname from hierarchy" do
      group.parent.update!(hostname: "parent.example.com")
      expect(subject).to eq "dummy-bounces+admin=hitobito.example.com@parent.example.com"
    end
  end
end
