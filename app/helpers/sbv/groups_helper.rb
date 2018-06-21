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
