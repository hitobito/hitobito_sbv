#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

CustomContent.seed_once(:key,
  {
    key: SongCensusMailer::SONG_CENSUS_REMINDER,
    placeholders_optional: 'recipient-name, recipient-first-name, verein, census-url, dachverband'
  },
  { key: HelpController::HELP_TEXT },
)

help_text_id = CustomContent.where(key: HelpController::HELP_TEXT).pluck(:id).first

CustomContent::Translation.seed_once(:custom_content_id, :locale,
  {
    custom_content_id: CustomContent.where(key: SongCensusMailer::SONG_CENSUS_REMINDER).first.id,
    locale: 'de',
    label: 'Meldeliste: E-Mail Erinnerung',
    subject: 'Meldeliste ausfüllen!',
    body: "Hallo {recipient-first-name} {recipient-name}<br/><br/>Wir bitten dich, die Meldeliste für den Verein '{verein}' einzureichen:<br/><br/>{census-url}<br/><br/>Vielen Dank für deine Mithilfe.<br/><br/>Dein {dachverband}"
  },

  {
    custom_content_id: help_text_id,
    locale: 'de',
    label: 'Hilfeseite für den Benutzer',
    subject: 'Hilfe und Unterstützung',
    body: '
      <ul>
        <li><a href="https://www.youtube.com/watch?v=-XPwxKcvS4c&amp;list=UUjGtTWlk8_HvhjCo8eVUmvw&amp;index=12" rel="nofollow">Tutorial 1: Intro und Profil</a></li>
        <li><a href="https://www.youtube.com/watch?v=vx8Q6dd_D6Y&amp;list=UUjGtTWlk8_HvhjCo8eVUmvw&amp;index=16" rel="nofollow">Tutorial 2: Gruppen erstellen</a></li>
        <li><a href="https://www.youtube.com/watch?v=nOiCYhJQwyg&amp;list=UUjGtTWlk8_HvhjCo8eVUmvw&amp;index=15" rel="nofollow">Tutorial 3: Suche</a></li>
        <li><a href="https://www.youtube.com/watch?v=dUX0c22AAbk&amp;list=UUjGtTWlk8_HvhjCo8eVUmvw&amp;index=14" rel="nofollow">Tutorial 4: Filter</a></li>
        <li><a href="https://www.youtube.com/watch?v=5F5_MnflbmY&amp;list=UUjGtTWlk8_HvhjCo8eVUmvw&amp;index=17" rel="nofollow">Tutorial 5: Emaillisten erstellen</a></li>
        <li><a href="https://www.youtube.com/watch?v=IONPi-Q8s2Y&amp;list=UUjGtTWlk8_HvhjCo8eVUmvw&amp;index=11" rel="nofollow">Tutorial 6: SUISA</a></li>
        <li><a href="https://www.youtube.com/watch?v=miMI-q9_OWE&amp;list=UUjGtTWlk8_HvhjCo8eVUmvw&amp;index=13" rel="nofollow" class="">Tutorial 7: SUISA-Listen exportieren</a></li>
        <li><a href="https://www.youtube.com/watch?v=I5GwrP0IJR0&amp;list=UUjGtTWlk8_HvhjCo8eVUmvw&amp;index=20" rel="nofollow">Tutorial 8: Veteranenwesen</a></li>
        <li><a href="https://www.youtube.com/watch?v=t8S9zVyuVXw&amp;list=UUjGtTWlk8_HvhjCo8eVUmvw&amp;index=19" rel="nofollow">Tutorial 9: Anlass erstellen</a></li>
        <li><a href="https://www.youtube.com/watch?v=H6c7c9mYXM8&amp;list=UUjGtTWlk8_HvhjCo8eVUmvw&amp;index=18" rel="nofollow" class="">Tutorial 10: Startdatum anpassen</a></li>
      </ul>
      '
  },
  {
    custom_content_id: help_text_id,
    locale: 'fr',
    label: "Page d'aide pour l'utilisateur",
    subject: 'Aide et support',
    body: '
      <ul>
        <li><a href="https://www.youtube.com/watch?v=ooIwdSbDyBM&amp;list=UUjGtTWlk8_HvhjCo8eVUmvw&amp;index=3" title="SBV_Tutorial01_Intro-Profil_FR.mp4" rel="nofollow">Tutorial 1: Introduction et profil</a></li>
        <li><a href="https://www.youtube.com/watch?v=jQWnaHuQpLA&amp;list=UUjGtTWlk8_HvhjCo8eVUmvw&amp;index=5" title="SBV_Tutorial02_Gruppe_erstellen_FR.mp4" rel="nofollow">Tutorial 2: Créer des groupes</a></li>
        <li><a href="https://www.youtube.com/watch?v=OgVRPOZBzHw&amp;list=UUjGtTWlk8_HvhjCo8eVUmvw&amp;index=4" title="SBV_Tutorial03_Suche_FR.mp4" rel="nofollow">Tutorial 3: Recherche</a></li>
        <li><a href="https://www.youtube.com/watch?v=m2ioUnrMsns&amp;list=UUjGtTWlk8_HvhjCo8eVUmvw&amp;index=6" title="SBV_Tutorial04_Filter_FR.mp4" rel="nofollow">Tutorial 4: Filtres</a></li>
        <li><a href="https://www.youtube.com/watch?v=ApCSuqcYLBk&amp;list=UUjGtTWlk8_HvhjCo8eVUmvw&amp;index=8" title="SBV_Tutorial05_emaillisten_erstellen_FR.mp4" rel="nofollow">Tutorial 5: Créer des listes mail</a></li>
        <li><a href="https://www.youtube.com/watch?v=f6Rd0TpZzK8&amp;list=UUjGtTWlk8_HvhjCo8eVUmvw&amp;index=1" title="SBV_Tutorial06_SUISA_FR.mp4" rel="nofollow">Tutorial 6: SUISA</a></li>
        <li><a href="https://www.youtube.com/watch?v=fPgFLzOd_oA&amp;list=UUjGtTWlk8_HvhjCo8eVUmvw" title="SBV_Tutorial07_SUISA_Listen_exportieren__FR.mp4" rel="nofollow">Tutorial 7: Exporter les listes SUISA</a></li>
        <li><a href="https://www.youtube.com/watch?v=PpFSydZl6Lw&amp;list=UUjGtTWlk8_HvhjCo8eVUmvw&amp;index=10" title="SBV_Tutorial08_veterans__FR.mp4" rel="nofollow">Tutorial 8: Vétérans</a></li>
        <li><a href="https://www.youtube.com/watch?v=aaOKmXa2HUg&amp;list=UUjGtTWlk8_HvhjCo8eVUmvw&amp;index=2" title="SBV_Tutorial09_Anlass_erstellen__FR.mp4" rel="nofollow">Tutorial 9: Créer une manifestation</a></li>
        <li><a href="https://www.youtube.com/watch?v=xb9bqwkGXq0&amp;list=UUjGtTWlk8_HvhjCo8eVUmvw&amp;index=9" title="SBV_Tutorial10_Startdatum_anpassen_FR.mp4" rel="nofollow">Tutorial 10: Adapter la date de début</a></li>
      </ul>'
  },
)
