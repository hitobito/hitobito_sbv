#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class SongCensusMailer < ApplicationMailer
  SONG_CENSUS_REMINDER = 'cong_census_reminder'.freeze

  def reminder(recipient, verein)
    custom_content_mail(recipient.email, SONG_CENSUS_REMINDER, mail_values(recipient, verein))
  end

  private

  def mail_values(recipient, verein)
    {
      'recipient-name' => recipient.last_name,
      'recipient-first-name' => recipient.first_name,
      'verein' => verein.name,
      'census-url' => link_to(group_song_counts_url(verein.id))
    }
  end
end
