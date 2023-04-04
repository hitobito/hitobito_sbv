# frozen_string_literal: true

#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::GroupsHelper

  def mitglieder_group_as_select_options
    Group::Verein::VereinMitglieder
      .with_deleted.includes(:parent)
      .where.not(parent: Group::Verein.hidden)
      .collect do |g|
        next unless g.parent

        [g.parent.name, g.id]
      end.compact.sort_by(&:first)
  end

  def swappable_group_add_fieldset(*keys)
    title = t('person.history.history_members_form_sbv.text_with_alternative_link_html',
              text: t(".#{keys.last}"),
              link: link_to(t(".#{keys.first}"), '#', data: { swap: 'group-fields' }))

    visible = keys.last == :select_existing_verein
    field_set_tag(title, class: 'group-fields', style: element_visible(visible)) { yield }
  end

  def format_correspondence_language(verein)
    Settings.application.correspondence_languages
            .to_h.stringify_keys[verein.correspondence_language.to_s]
  end

  def format_unterhaltungsmusik(verein)
    verein.unterhaltungsmusik_label
  end

  def format_klasse(verein)
    verein.klasse_label
  end

  def format_besetzung(verein)
    verein.besetzung_label
  end

  def subgroups_checkboxes(groups, root)
    hash = {}
    groups.without_deleted.includes([:parent]).group_by(&:parent_id).values.each do |grouping|
      if grouping.first.parent_id == root.id
        hash[root] = {}
        hash[root][root] = grouping
      else
        hash.deep_merge!(create_nesting(grouping, root) do
          b = Hash.new
          b[grouping.first.parent] = grouping
          b
        end)
      end
    end

    nested_verein_checkbox(hash, root)
  end

  def create_nesting(group, root)
    parent = Array.wrap(group).first.parent
    if parent.id == root.id
      hash = {}
      hash[parent] = yield
      return hash
    end

    create_nesting(parent, root) do
      hash = {}
      hash[parent] = yield
      hash
    end
  end

  def nested_verein_checkbox(hash, root)
    safe_join(hash.map do |parent, vereine_or_nested_structure|
      content_tag(:div, class: 'verein_fee_nesting') do
        content = content_tag(:h3) do
          parent.name if vereine_or_nested_structure.is_a?(Hash)
        end
        content << content_tag(:div, class: 'verein_fee_nesting') do
          if vereine_or_nested_structure.is_a?(Hash)
            nested_verein_checkbox(vereine_or_nested_structure, root)
          elsif vereine_or_nested_structure.is_a?(Array)
            safe_join(vereine_or_nested_structure.map do |verein|
              content_tag(:div, class: 'control-group') do
                recipient_id = InvoiceLists::VereinMembershipFeeRecipientFinder.find_recipient(verein.id)
                next unless recipient_id
                label_tag(nil, class: 'checkbox') do
                  out = check_box_tag('ids[]',
                                      recipient_id,
                                      true,
                                      id: 'invoice_list_ids_',
                                      data: { multiselect: true })
                  out << verein.name
                  out.html_safe
                end
              end
            end, '')
          end
        end
      end
    end,'')
  end
end
