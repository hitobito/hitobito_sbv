# frozen_string_literal: true

#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_pbs and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_pbs.

class HelpController < ApplicationController
  HELP_TEXT = "controller/help_text"

  skip_authorization_check only: [:index]

  def index
    @content = CustomContent.get(HELP_TEXT)
  end
end
