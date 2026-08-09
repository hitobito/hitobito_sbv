# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class Roles::InstrumentsController < ApplicationController
  before_action :entry

  respond_to :js, only: [:destroy]

  def destroy
    authorize!(:update, entry)
    entry.update!(instrument: nil)
    @person = entry.person
  end

  private

  def entry
    @entry ||= Role.find(params[:role_id])
  end
  helper_method :entry
end
