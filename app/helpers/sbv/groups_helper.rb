# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::GroupsHelper

  def format_correspondence_language(verein)
    Settings.application.languages.to_h.stringify_keys[verein.correspondence_language]
  end

  def format_unterhaltungsmusik(verein)
    verein.unterhaltungsmusik_label
  end

  def format_klasse(verein)
    verein.klasse_label
  end

  def format_besetzung(verein)
    verein.besetzung_label
  end

end
