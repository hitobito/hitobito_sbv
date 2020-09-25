# Hitobito Schweizer Blasmusikverband

This hitobito wagon defines the organization hierarchy with groups and roles
of the Schweizer Blasmusikverband.


## Organization Hierarchy

* Generalverband
  * Generalverband
    * Administrator: [:layer_and_below_full, :admin, :impersonation, :finance, :uv_lohnsumme]
* Dachverband
  * Dachverband
    * Administrator: [:layer_and_below_full, :admin, :impersonation, :finance, :song_census, :uv_lohnsumme]
    * Verantwortlicher SUISA: [:group_read, :song_census]
  * Geschäftsstelle
    * Geschäftsführung: [:layer_and_below_full, :impersonation]
    * Mitarbeiter: [:layer_and_below_full, :approve_applications, :finance]
    * Hilfe: [:layer_and_below_read]
  * Verbandsleitung
    * Präsident: [:layer_full, :layer_and_below_read]
    * Vizepräsident: [:layer_and_below_read]
    * Finanzchef: [:layer_and_below_read, :finance]
    * Veteranenchef: [:layer_and_below_read]
    * Mitglied: [:layer_and_below_read]
  * Musikkommission
    * Präsident: [:layer_read, :group_and_below_full]
    * Mitglied: [:layer_read]
  * Arbeitsgruppe
    * Leitung: [:layer_read]
    * Mitglied: [:group_and_below_read]
  * Kontakte
    * Adressverwaltung: [:group_and_below_full]
    * Kontakt: []
  * Ehrenmitglieder
    * Adressverwaltung: [:group_and_below_full]
    * Ehrenmitglied: []
  * Veteranen
    * Eidgenössischer Veteran: []
    * Eidgenössicher Ehrenveteran: []
    * CISM Veteran: []
* Mitgliederverband
  * Mitgliederverband
    * Administrator: [:layer_and_below_full, :uv_lohnsumme]
    * Verantwortlicher SUISA: [:group_read, :song_census]
  * Geschäftsstelle
    * Geschäftsführung: [:layer_and_below_full, :finance]
    * Mitarbeiter: [:layer_and_below_full, :approve_applications, :finance]
    * Hilfe: [:layer_and_below_read]
  * Vorstand
    * Präsident: [:layer_full, :layer_and_below_read]
    * Vizepräsident: [:layer_and_below_read]
    * Kassier: [:layer_and_below_read, :finance]
    * Veteranenchef: [:layer_and_below_read]
    * Mitglied: [:layer_and_below_read]
  * Musikkommission
    * Präsident: [:layer_read, :group_and_below_full]
    * Mitglied: [:layer_read]
  * Arbeitsgruppe
    * Leitung: [:layer_read]
    * Mitglied: [:group_and_below_read]
  * Kontakte
    * Adressverwaltung: [:group_and_below_full]
    * Kontakt: []
  * Veteranen
    * Kantonaler Veteran: []
    * Kantonaler Ehrenveteran: []
* Regionalverband
  * Regionalverband
    * Administrator: [:layer_and_below_full]
    * Verantwortlicher SUISA: [:group_read, :song_census]
  * Geschäftsstelle
    * Geschäftsführung: [:layer_and_below_full, :finance]
    * Mitarbeiter: [:layer_and_below_full, :approve_applications, :finance]
    * Hilfe: [:layer_and_below_read]
  * Vorstand
    * Präsident: [:layer_full, :layer_and_below_read]
    * Vizepräsident: [:layer_and_below_read]
    * Kassier: [:layer_and_below_read, :finance]
    * Veteranenchef: [:layer_and_below_read]
    * Mitglied: [:layer_and_below_read]
  * Musikkommission
    * Präsident: [:layer_read, :group_and_below_full]
    * Mitglied: [:layer_read]
  * Arbeitsgruppe
    * Leitung: [:layer_read]
    * Mitglied: [:group_and_below_read]
  * Kontakte
    * Adressverwaltung: [:group_and_below_full]
    * Kontakt: []
* Verein
  * Verein
    * Administrator: [:layer_and_below_full, :festival_participation, :uv_lohnsumme]
    * DirigentIn: []
    * Verantwortlicher SUISA: [:group_read, :song_census]
  * Vorstand
    * Präsident: [:layer_full, :layer_and_below_read]
    * Vizepräsident: [:layer_and_below_read]
    * Kassier: [:layer_and_below_read, :finance]
    * Veteranenchef: [:layer_and_below_read]
    * Materialverwaltung: [:layer_and_below_read]
    * Mitglied: [:layer_and_below_read]
  * Musikkommission
    * Präsident: [:layer_read, :group_and_below_full]
    * Mitglied: [:layer_read]
  * Mitglieder
    * Adressverwaltung: [:group_and_below_full]
    * Mitglied: [:layer_read]
    * Passivmitglied: []
    * Ehrenmitglied: []
  * Arbeitsgruppe
    * Leitung: [:layer_read]
    * Mitglied: [:group_and_below_read]
  * Kontakte
    * Adressverwaltung: [:group_and_below_full]
    * Kontakt: []

(Output of rake app:hitobito:roles)


## weiteren Musikerverband hinzufügen

Die Gruppenstruktur ist darauf ausgelegt, mehrere Dachverbände in einer
Superstruktur (dem Generalverband) zu organisieren.

Um einen weiteren Verband von Musikern hinzuzufügen, sind jedoch ein paar
manuelle Schritte nötig, die nicht alle in hitobito direkt erledigt werden
können:

* neue Dachverband-Gruppe in hitobito Generalverband anlegen
  * Domain auf Dachverband-Gruppe eintragen
  * Logo für Musikerverband hochladen
* DNS-Eintrag machen, um Domain auf SBV-Hitobito zeigen zu lassen
  * Verantwortlichkeit: Domaininhaber
* OpenShift-Route anlegen, um Domain von SBV-Hitobito verarbeiten zu lassen
  * Route ins kustomize-git aufnehmen
  * Verantwortlichkeit: Ops-Team Hitobito
* Eintrag in Mailkonfiguration machen, um mail an neue Domain in das richtige Postfach zu schieben
  * analog dem bestehenden catch-call regexp für SBV:
  * `/(.+)@hitobito\.domain\.tld/ mailaccount+$1@maildomain.tld`
  * Verantwortlichkeit: Sys-Team Hitobito

