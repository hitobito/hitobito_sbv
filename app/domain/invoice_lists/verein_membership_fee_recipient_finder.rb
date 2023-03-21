
class InvoiceLists::VereinMembershipFeeRecipientFinder
  def self.find_recipient(verein_id)
    vorstand_id = Group::VereinVorstand.where(parent_id: verein_id).first.id

    recipient_role = Group::VereinVorstand::Kassier.find_by(group_id: vorstand_id) ||
      Group::VereinVorstand::Praesident.find_by(group_id: vorstand_id) ||
      Group::Verein::Admin.find_by(group_id: verein_id)

    recipient_role&.person_id
  end

  def self.find_verein(recipient_id)
    recipient_role = Group::VereinVorstand::Kassier.find_by(person_id: recipient_id) ||
      Group::VereinVorstand::Praesident.find_by(person_id: recipient_id) ||
      Group::Verein::Admin.find_by(person_id: recipient_id)

    recipient_role.group.layer_group
  end
end
