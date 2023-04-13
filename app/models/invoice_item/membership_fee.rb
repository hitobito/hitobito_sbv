# frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class InvoiceItem::MembershipFee < InvoiceItem
  self.dynamic = true

  self.dynamic_cost_parameter_definitions = {
    cutoff_date: :date,
    amount: :number
  }

  def dynamic_cost
    return if dynamic_cost_parameters[:recipient_id].blank?

    amount = dynamic_cost_parameters[:amount]
    cutoff_date = Date.parse(dynamic_cost_parameters[:cutoff_date])
    recipient_id = dynamic_cost_parameters[:recipient_id]

    layer = InvoiceLists::VereinMembershipFeeRecipientFinder.find_verein(recipient_id)

    member_count = if layer.manually_counted_members?
                     layer.manual_member_count
                   else
                     Role.with_deleted
                         .joins(:group)
                         .where('roles.deleted_at IS NULL OR roles.deleted_at > ?', cutoff_date)
                         .where(created_at: ...cutoff_date,
                                type: Group::VereinMitglieder::Mitglied.sti_name,
                                group: { layer_group_id: layer.id }).count
                   end

    amount * member_count
  end
end
