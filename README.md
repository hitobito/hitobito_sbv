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






