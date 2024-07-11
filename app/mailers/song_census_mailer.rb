# frozen_string_literal: true

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class SongCensusMailer < ApplicationMailer
  SONG_CENSUS_REMINDER = "cong_census_reminder"

  def reminder(recipient, verein)
    @recipient = recipient
    @verein = verein
    compose(recipient, SONG_CENSUS_REMINDER)
  end

  private

  def placeholder_dachverband
    @verein.self_and_ancestors.find_by(type: Group::Root.sti_name).to_s
  end

  def placeholder_recipient_name
    @recipient.last_name
  end

  def placeholder_recipient_first_name
    @recipient.first_name
  end

  def placeholder_verein
    @verein.name
  end

  def placeholder_census_url
    link_to(group_song_counts_url(@verein.id))
  end
end
