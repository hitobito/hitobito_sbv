# frozen_string_literal: true
#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class SongsController < SimpleCrudController

  self.search_columns = [:title]
  self.permitted_attrs = [:title, :composed_by, :arranged_by, :published_by]

  decorates :song

  respond_to :json, :js

  def create
    assign_attributes
    created = with_callbacks(:create, :save) { save_entry }

    respond_to do |format|
      format.html { respond_with(entry, notice: flash_message(:success)) }
      format.js do
        set_created_js_flash_message(created)
        respond_with(entry)
      end
    end
  end

  def index
    respond_to do |format|
      format.html { @songs = entries.page(params[:page]) }
      format.json { render json: with_create(for_typeahead(entries.page)) }
    end
  end

  private

  def with_create(list)
    return list if list.size > 3

    list + [{ label: I18n.t('crud.new.title', model: model_class.model_name.human) }]
  end

  def for_typeahead(entries)
    entries.collect do |entry|
      attributes = entry.attributes.map { |key, value| [key, h(value)] }.to_h
      attributes.merge(label: entry.decorate.full_label)
    end
  end

  def failure_notice
    error_messages.presence || flash_message(:failure)
  end

  def set_created_js_flash_message(created) # rubocop:disable Naming/AccessorMethodName
    if created
      flash.now[:notice] = flash_message(:success)
    else
      flash.now[:alert] = failure_notice
    end
  end

end
