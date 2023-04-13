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
    nested_verein_checkboxes(vereine_nesting(groups, root), root)
  end

  def vereine_nesting(groups, root)
    groups.without_deleted.includes([:parent])
                          .group_by(&:parent_id)
                          .values.each_with_object({}) do |vereine_by_parent, global_nesting|
      parent = vereine_by_parent.first.parent

      if parent.id == root.id
        global_nesting[root] = {}
        global_nesting[root][root] = vereine_by_parent
      else
        nesting = create_vereine_nesting(vereine_by_parent, root) do
          verein_nesting = {}
          verein_nesting[parent] = vereine_by_parent
          verein_nesting
        end

        global_nesting.deep_merge!(nesting)
      end
    end
  end

  def create_vereine_nesting(group, root)
    parent = Array.wrap(group).first.parent
    if parent.id == root.id
      hash = {}
      hash[parent] = yield
      return hash
    end

    create_vereine_nesting(parent, root) do
      hash = {}
      hash[parent] = yield
      hash
    end
  end

  def nested_verein_checkboxes(hash, root)
    safe_join(hash.map do |parent, vereine_or_nested_structure|
      content_tag(:div, class: 'verein_fee_nesting') do
        content = ActiveSupport::SafeBuffer.new
        if vereine_or_nested_structure.is_a?(Hash)
          content << content_tag(:h3) do
            parent.name
          end
        end
        content << content_tag(:div, class: 'verein_fee_nesting') do
          if vereine_or_nested_structure.is_a?(Hash)
            nested_verein_checkboxes(vereine_or_nested_structure, root)
          elsif vereine_or_nested_structure.is_a?(Array)
            safe_join(vereine_or_nested_structure.map { |verein| verein_checkbox(verein) }, '')
          end
        end
      end
    end,'')
  end

  def verein_checkbox(verein)
    content_tag(:div, class: 'control-group') do
      recipient = InvoiceLists::VereinMembershipFeeRecipientFinder.find_recipient(verein.id)
      info_text = t(".info.#{recipient&.class&.sti_name&.parameterize || 'no_recipient'}")
      label_tag(nil, class: 'checkbox', title: info_text) do
        out = check_box_tag('ids[]',
                            recipient&.id,
                            recipient&.id.present?,
                            id: 'ids_',
                            disabled: recipient&.id.nil?,
                            data: { multiselect: true })
        out << verein.name
        out << ' '
        out << icon(:info)
        out.html_safe
      end
    end
  end
end
