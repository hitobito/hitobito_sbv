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
    cutoff_date = begin
      Date.parse(dynamic_cost_parameters[:cutoff_date])
    rescue
      nil
    end

    recipient_id = dynamic_cost_parameters[:recipient_id]

    member_count = member_count_for_dynamic_cost(recipient_id, cutoff_date)

    amount.to_i * member_count
  end

  def member_count_for_dynamic_cost(recipient_id, cutoff_date)
    layer = InvoiceRuns::VereinMembershipFeeRecipientFinder.find_verein(recipient_id)

    if layer.uses_manually_counted_members?
      layer.manual_member_count
    else
      roles_scope = Role.with_inactive.joins(:group)
        .where(type: Group::VereinMitglieder::Mitglied.sti_name,
          group: {layer_group_id: layer.id})
      if cutoff_date.present?
        roles_scope.active(cutoff_date)
      else
        roles_scope
      end.count
    end
  end
end
