# frozen_string_literal: true

#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::MailRelay::Lists
  extend ActiveSupport::Concern

  def envelope_sender
    self.class.personal_return_path(envelope_receiver_name, sender_email, mail_domain)
  end

  def mail_domain
    # fallback to list_domain for reject_not_existing
    mailing_list&.mail_domain || Settings.email.list_domain
  end

end
