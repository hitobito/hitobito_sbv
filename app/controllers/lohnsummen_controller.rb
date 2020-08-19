# frozen_string_literal: true
#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class LohnsummenController < ApplicationController
  skip_authorize_resource
  before_action :authorize_class

  def show
    groups = group.descendants.where(type: 'Group::Verein')
    csv = Export::Tabular::Groups::LohnsummenList.csv(groups)
    send_data csv, type: :csv, disposition: 'attachment'
  end

  private

  def authorize_class
    authorize!(:show_uv_lohnsummen, group)
  end

  def group
    @group ||= Group.find(params[:group_id])
  end

end
