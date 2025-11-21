# frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class InvoiceRuns::VereinMembershipFeeRecipientFinder
  def self.find_recipient(verein_id)
    vorstand_id = Group::VereinVorstand.find_by(parent_id: verein_id)&.id
    admin_role = Group::Verein::Admin.find_by(group_id: verein_id)

    return admin_role if vorstand_id.blank?

    Group::VereinVorstand::Kassier.find_by(group_id: vorstand_id) ||
      Group::VereinVorstand::Praesident.find_by(group_id: vorstand_id) ||
      admin_role
  end

  def self.find_verein(recipient_id)
    recipient_role = Group::VereinVorstand::Kassier.find_by(person_id: recipient_id) ||
      Group::VereinVorstand::Praesident.find_by(person_id: recipient_id) ||
      Group::Verein::Admin.find_by(person_id: recipient_id)

    recipient_role.group.layer_group
  end
end
