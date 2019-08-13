#  Copyright (c) 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::MailRelay::Lists
  extend ActiveSupport::Concern

  def envelope_sender
    super(envelope_receiver_name, sender_mail, mail_domain)
  end

  def mail_domain
    mailing_list.mail_domain
  end

end
