# frozen_string_literal: true

#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::ApplicationMailer
  extend ActiveSupport::Concern

  def return_path(sender)
    MailRelay::Lists.personal_return_path(MailRelay::Lists.app_sender_name,
      sender.email,
      sender.primary_group.try(:hostname_from_hierarchy))
  end
end
