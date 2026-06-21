# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::PaperTrail::VersionAssociationChangePresenter
  CREATE_LOGGED_ROLE_ATTRIBUTES = %w[instrument].freeze

  def render
    h.content_tag(:div) do
      changeset_text = case event
      when "update" then changeset_list
      when "create" then role_create_changeset_list
      end

      text = association_change_text(changeset_text)
      h.sanitize(text, tags: %w[i])
    end
  end

  private

  def changeset_list
    presenter = PaperTrail::VersionChangesetPresenter.new(version, h)

    rendered_changes = changeset.filter_map do |attr, (from, to)|
      presenter.attribute_change(attr, from, to).presence
    end

    h.safe_join(rendered_changes, ", ")
  end

  def role_create_changeset_list
    return unless item_type == "Role"

    presenter = PaperTrail::VersionChangesetPresenter.new(version, h)
    rendered_changes = CREATE_LOGGED_ROLE_ATTRIBUTES.filter_map do |attr|
      from, to = changeset_value(attr)
      next if to.blank?

      presenter.attribute_change(attr, from, to).presence
    end

    h.safe_join(rendered_changes, ", ") if rendered_changes.any?
  end

  def changeset_value(attr)
    changeset[attr] || changeset[attr.to_sym]
  end

  def association_change_text(changeset)
    if event == "create" && item_type == "Role" && changeset.present?
      I18n.t(
        "version.association_change.role.create_with_attributes",
        model: item_class.model_name.human,
        label: item_label || label_with_fallback(reifyed_item),
        changeset: changeset
      )
    else
      super
    end
  end
end
