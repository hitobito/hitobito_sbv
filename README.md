# Hitobito Schweizer Blasmusikverband

This hitobito wagon defines the organization hierarchy with groups and roles
of the Schweizer Blasmusikverband.


## Organization Hierarchy

* Generalverband
  * Generalverband
    * Administrator: [:layer_and_below_full, :admin, :impersonation, :finance]
* Dachverband
  * Dachverband
    * Administrator: [:group_and_below_full, :admin, :impersonation, :finance, :song_census]
    * Verantwortlicher SUISA: [:group_read, :song_census]
  * Geschäftsstelle
    * Geschäftsführung: [:layer_and_below_full, :contact_data, :impersonation]
    * Mitarbeiter: [:layer_and_below_full, :contact_data, :approve_applications, :finance]
    * Hilfe: [:layer_and_below_read, :contact_data]
  * Verbandsleitung
    * Präsident: [:layer_full, :layer_and_below_read, :contact_data]
    * Vizepräsident: [:layer_and_below_read, :contact_data]
    * Finanzchef: [:layer_and_below_read, :contact_data, :finance]
    * Veteranenchef: [:layer_and_below_read, :contact_data]
    * Mitglied: [:layer_and_below_read, :contact_data]
  * Musikkommission
    * Präsident: [:layer_read, :group_and_below_full]
    * Mitglied: [:layer_read]
  * Arbeitsgruppe
    * Leitung: [:layer_read, :contact_data]
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
    * Administrator: [:layer_and_below_full]
    * Verantwortlicher SUISA: [:group_read, :song_census]
  * Geschäftsstelle
    * Geschäftsführung: [:layer_and_below_full, :contact_data, :finance]
    * Mitarbeiter: [:layer_and_below_full, :contact_data, :approve_applications, :finance]
    * Hilfe: [:layer_and_below_read, :contact_data]
  * Vorstand
    * Präsident: [:layer_full, :layer_and_below_read, :contact_data]
    * Vizepräsident: [:layer_and_below_read, :contact_data]
    * Kassier: [:layer_and_below_read, :contact_data, :finance]
    * Veteranenchef: [:layer_and_below_read, :contact_data]
    * Mitglied: [:layer_and_below_read, :contact_data]
  * Musikkommission
    * Präsident: [:layer_read, :group_and_below_full]
    * Mitglied: [:layer_read]
  * Arbeitsgruppe
    * Leitung: [:layer_read, :contact_data]
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
    * Geschäftsführung: [:layer_and_below_full, :contact_data, :finance]
    * Mitarbeiter: [:layer_and_below_full, :contact_data, :approve_applications, :finance]
    * Hilfe: [:layer_and_below_read, :contact_data]
  * Vorstand
    * Präsident: [:layer_full, :layer_and_below_read, :contact_data]
    * Vizepräsident: [:layer_and_below_read, :contact_data]
    * Kassier: [:layer_and_below_read, :contact_data, :finance]
    * Veteranenchef: [:layer_and_below_read, :contact_data]
    * Mitglied: [:layer_and_below_read, :contact_data]
  * Musikkommission
    * Präsident: [:layer_read, :group_and_below_full]
    * Mitglied: [:layer_read]
  * Arbeitsgruppe
    * Leitung: [:layer_read, :contact_data]
    * Mitglied: [:group_and_below_read]
  * Kontakte
    * Adressverwaltung: [:group_and_below_full]
    * Kontakt: []
* Verein
  * Verein
    * Administrator: [:layer_and_below_full]
    * DirigentIn: [:contact_data]
    * Verantwortlicher SUISA: [:group_read, :song_census]
  * Vorstand
    * Präsident: [:layer_full, :layer_and_below_read, :contact_data]
    * Vizepräsident: [:layer_and_below_read, :contact_data]
    * Kassier: [:layer_and_below_read, :contact_data, :finance]
    * Veteranenchef: [:layer_and_below_read, :contact_data]
    * Materialverwaltung: [:layer_and_below_read, :contact_data]
    * Mitglied: [:layer_and_below_read, :contact_data]
  * Musikkommission
    * Präsident: [:layer_read, :group_and_below_full]
    * Mitglied: [:layer_read]
  * Mitglieder
    * Adressverwaltung: [:group_and_below_full]
    * Mitglied: [:layer_read]
    * Passivmitglied: []
    * Ehrenmitglied: []
  * Arbeitsgruppe
    * Leitung: [:layer_read, :contact_data]
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

