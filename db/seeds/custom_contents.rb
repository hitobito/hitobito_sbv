#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

CustomContent.seed_once(:key,
  {
    key: SongCensusMailer::SONG_CENSUS_REMINDER,
    placeholders_optional: 'recipient-name, recipient-first-name, verein, census-url'
  },
)

CustomContent::Translation.seed_once(:custom_content_id, :locale,
  {
    custom_content_id: CustomContent.where(key: SongCensusMailer::SONG_CENSUS_REMINDER).first.id,
    locale: 'de',
    label: 'Meldeliste: E-Mail Erinnerung',
    subject: 'Meldeliste ausfüllen!',
    body: "Hallo {recipient-first-name} {recipient-name}<br/><br/>Wir bitten dich, die Meldeliste für den Verein '{verein}' einzureichen:<br/><br/>{census-url}<br/><br/>Vielen Dank für deine Mithilfe.<br/><br/>Dein Schweizer Blasmusikverband"
  },
)
