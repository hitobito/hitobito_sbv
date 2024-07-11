#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

describe MailingList do
  let(:group) { groups(:kontakte_5) }

  context "#mail_domain" do
    subject { MailingList.new(group: group).mail_domain }

    it "#mail_domain falls back to settings" do
      expect(subject).to eq Settings.email.list_domain
    end

    it "#mail_domain might read hostname from group" do
      group.update(hostname: "example.com")
      expect(subject).to eq "example.com"
    end

    it "#mail_domain might read hostname from hierarchy" do
      group.parent.update(hostname: "example.com")
      expect(subject).to eq "example.com"
    end
  end
end
