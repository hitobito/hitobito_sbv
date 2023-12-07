# frozen_string_literal: true

#  Copyright (c) 2023, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class SubvereinCheckboxesBuilder

  I18N_PREFIX = 'groups.subverein_select_modal'


  attr_reader :subvereine, :root, :template

  delegate :safe_join, :content_tag,
           :check_box_tag, :label_tag, :icon, to: :template

  def initialize(root, template)
    @template = template
    @root = root

    @subvereine = Group::Verein.where(id: root.descendants.pluck(:id))
  end

  def self.checkboxes(root, template)
    builder = new(root, template)

    builder.to_html
  end

  def to_html
    if subvereine.present?
      content = label_tag(nil, class: 'checkbox mb-2') do |content|
        content = check_box_tag(:all, 0, true, data: :multiselect)
        content << I18n.t("#{I18N_PREFIX}.select_all")
      end

      content << nested_verein_checkboxes(vereine_nesting)
    else
      I18n.t("#{I18N_PREFIX}.no_entries")
    end
  end

  private

  def vereine_nesting
    subvereine.without_deleted.includes([:parent])
                              .group_by(&:parent_id)
                              .values.each_with_object({}) do |vereine_by_parent, global_nesting|
      parent = vereine_by_parent.first.parent

      if parent.id == root.id
        global_nesting[root] = {}
        global_nesting[root][root] = vereine_by_parent
      else
        nesting = create_vereine_nesting(vereine_by_parent) do
          verein_nesting = {}
          verein_nesting[parent] = vereine_by_parent
          verein_nesting
        end

        global_nesting.deep_merge!(nesting)
      end
    end
  end

  def create_vereine_nesting(group)
    parent = Array.wrap(group).first.parent
    if parent.id == root.id
      hash = {}
      hash[parent] = yield
      return hash
    end

    create_vereine_nesting(parent) do
      hash = {}
      hash[parent] = yield
      hash
    end
  end

  def nested_verein_checkboxes(hash)
    safe_join(hash.map do |parent, vereine_or_nested_structure|
      content_tag(:div, class: 'verein_fee_nesting mb-3') do
        content = ActiveSupport::SafeBuffer.new
        if vereine_or_nested_structure.is_a?(Hash)
          content << content_tag(:h3) do
            parent.name
          end
        end
        content << content_tag(:div, class: 'verein_fee_nesting') do
          if vereine_or_nested_structure.is_a?(Hash)
            nested_verein_checkboxes(vereine_or_nested_structure)
          elsif vereine_or_nested_structure.is_a?(Array)
            safe_join(vereine_or_nested_structure.map { |verein| verein_checkbox(verein) }, '')
          end
        end
      end
    end,'')
  end

  def verein_checkbox(verein)
    content_tag(:div, class: 'control-group mb-1') do
      recipient = InvoiceLists::VereinMembershipFeeRecipientFinder.find_recipient(verein.id)
      info_key = recipient&.class&.sti_name&.parameterize || 'no_recipient'
      info_text = I18n.t("#{I18N_PREFIX}.info.#{info_key}")
      label_tag(nil, class: 'checkbox', title: info_text) do
        out = check_box_tag('ids[]',
                            recipient&.person_id,
                            recipient.present?,
                            id: 'ids_',
                            disabled: recipient.nil?,
                            data: { multiselect: true })
        out << verein.name
        out << ' '
        out << icon(:info)
        out.html_safe
      end
    end
  end
end
