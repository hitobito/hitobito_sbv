#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class Groups::QueryController < ApplicationController

  before_action :authorize_action

  delegate :model_class, to: :class

  # GET ajax, for auto complete fields
  def index
    groups = []
    if params.key?(:q) && params[:q].size >= 3
      groups = list_entries.limit(10)
      groups = decorate(groups)
    end

    render json: groups.collect(&:as_typeahead)
  end

  private

  def list_entries
    Group::Verein.all
  end

  def authorize_action
    authorize!(:query, Group)
  end

  include Searchable

  self.search_columns = [:name, :short_name, :town, :vereinssitz]

  class << self

    def model_class
      Group
    end

  end

end
