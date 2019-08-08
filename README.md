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

## ToDos

* hitobito-sbv@puzzle.ch Alias erstellen und in settings.yml als rootuser hinterlegen. Bittea auf hitobito-intern@puzzle.ch weiterleiten lassen (wie bei den anderen).
* Merhsprachigkeit abklären und anpassen in `config/settings.yml`


### Anleitung: Wagon erstellen


Damit entsprechende Testdaten für Tests sowie Tarantula vorhanden sind, müssen die Fixtures im Wagon entsprechend der generierten Organisationsstruktur angepasst werden.
* Anpassen der Fixtures für people, groups, roles, events, usw. (`spec/fixtures`)
* Anpassen der Tarantula Tests im Wagon (`test/tarantula/tarantula_test.rb`)

=======

### Anleitung: Gruppenstruktur definieren

Nachdem für eine Organisation ein neuer Wagon erstellt worden ist, muss oft auch eine
Gruppenstruktur definiert werden. Wie die entsprechenden Modelle aufgebaut sind, ist in der
Architekturdokumentation beschrieben. Hier die einzelnen Schritte, welche für das Aufsetzen der
Entwicklungsumgebung noch vorgenommen werden müssen:

* Am Anfang steht die alleroberste Gruppe. Die Klasse in `app/models/group/root.rb` entsprechend
  umbenennen (z.B. nach "Dachverband") und erste Rollen definieren.
* `app/models/[name]/group.rb#root_types` entsprechend anpassen.
* In `config/locales/models.[name].de.yml` Übersetzungen für Gruppe und Rollen hinzufügen.
* In `db/seed/development/1_people.rb` die Admin Rolle für die Entwickler anpassen.
* In `db/seed/groups.rb` den Seed der Root Gruppe anpassen.
* In `spec/fixtures/groups.yml` den Typ der Root Gruppe anpassen.
* In `spec/fixtures/roles.yml` die Rollentypen anpassen.
* Tests ausführen
* Weitere Gruppen und Rollen inklusive Übersetzungen definieren.
* In `db/seed/development/0_groups.rb` Seed Daten für die definierten Gruppentypen definieren.
* In `spec/fixtures/groups.yml` Fixtures für die definierten Gruppentypen definieren. Es empfielt
  sich, die selben Gruppen wie in den Development Seeds zu verwenden.
* `README.md` mit Output von `rake app:hitobito:roles` ergänzen.
