# rubocop:disable Metrics/BlockLength
namespace :migration do
  task :clean do
    rm_f 'db/seeds/production/verbaende.csv'
    rm_f 'db/seeds/production/vereine.csv'
    rm_f 'db/seeds/production/vereine_musicgest.csv'
    rm_f 'db/seeds/production/mitglieder.csv'
    rm_f 'db/seeds/production/mitglieder_musicgest.csv'
    rm_f 'db/seeds/production/suisa_werke.csv'
    # rm_f 'db/seeds/production/suisa_meldungen.csv'
    rm_f 'db/seeds/production/rollen_musicgest.csv'
  end

  task extract: [
    'db/seeds/production/verbaende.csv',
    'db/seeds/production/vereine.csv',
    'db/seeds/production/vereine_musicgest.csv',
    'db/seeds/production/mitglieder.csv',
    'db/seeds/production/mitglieder_musicgest.csv',
    'db/seeds/production/suisa_werke.csv',
    # 'db/seeds/production/suisa_meldungen.csv',
    'db/seeds/production/rollen_musicgest.csv'
  ]

  task prepare_seed: [:extract] do
    rm_f 'db/seeds/groups.rb'
    rm_rf 'db/seeds/development'

    cp 'db/seeds/production/0_groups.rb', 'db/seeds/0_groups.rb'
    cp 'db/seeds/production/1_people.rb', 'db/seeds/1_people.rb'
    cp 'db/seeds/production/2_songs.rb', 'db/seeds/2_songs.rb'
    # cp 'db/seeds/production/3_census.rb', 'db/seeds/3_census.rb'
    cp 'db/seeds/production/4_roles.rb', 'db/seeds/4_roles.rb'
  end

  task :repair_after_seed do
    puts 'git checkout db/seeds/development'
    puts 'git checkout db/seeds/groups.rb'
    puts 'git clean -f'
  end
end

directory 'db/seeds/production'

file 'db/seeds/production/verbaende.csv' => 'db/seeds/production' do |task|
  migrator = Migration.new(task.name, 'swoffice_sbvnew')
  migrator.headers = <<-TEXT.strip_heredoc
    name,email,country,town,zip_code,address,vereinssitz,founding_year,subventionen,type
  TEXT
  migrator.query('tbl_person', <<-SQL.strip_heredoc, <<-CONDITIONS.strip_heredoc)
    name,
    email,
    laendercode AS country,
    ort AS town,
    plz AS zip_code,
    strasse AS address,
    domizil AS vereinssitz,
    COALESCE(NULLIF(gruendungsjahr, ''), 0) AS founding_year,
    subvention AS subventionen,
    CASE typ
      WHEN 'bund' THEN 'Group::Root'
      WHEN 'verband' THEN 'Group::Mitgliederverband'
    END AS 'type'
  SQL
    WHERE typ IN ('bund', 'verband')
  CONDITIONS
  # faxGeschaeft, faxPrivat, telGeschaeft, homepage, hinweis, zusatz, konto, kreisverbaende,
  migrator.dump
end

file 'db/seeds/production/vereine.csv' => 'db/seeds/production' do |task|
  migrator = Migration.new(task.name, 'swoffice_sbvnew')
  migrator.headers = <<-TEXT.strip_heredoc
    name,email,country,town,zip_code,address,vereinssitz,founding_year,subventionen,type,verband,besetzung,correspondence_language,reported_members,kreis
  TEXT
  migrator.query('tbl_person', <<-SQL.strip_heredoc, <<-CONDITIONS.strip_heredoc)
    CONCAT_WS(' ', tbl_person.name, tbl_person.domizil) AS name,
    tbl_person.email,
    tbl_person.laendercode AS country,
    tbl_person.ort AS town,
    tbl_person.plz AS zip_code,
    tbl_person.strasse AS address,
    tbl_person.domizil AS vereinssitz,
    COALESCE(NULLIF(tbl_person.gruendungsjahr, ''), 0) AS founding_year,
    tbl_person.subvention AS subventionen,
    'Group::Verein' AS 'type',
    concat(verbaende.name) AS verband,
    tbl_person.besetzung,
    tbl_person.amtssprache AS correspondence_language,
    tbl_person.anzahlmitgliederSoll AS reported_members,
    tbl_person.kreis
  SQL
    INNER JOIN tbl_person AS verbaende ON ( tbl_person.parentId = verbaende.id )
    WHERE tbl_person.typ IN ('verein')
    AND tbl_person.parentId NOT IN (1577, 1743, 2784, 4729, 4751, 4809)
  CONDITIONS
  # faxGeschaeft, faxPrivat, telGeschaeft, homepage, hinweis, zusatz, konto, kreisverbaende,
  migrator.dump
end

file 'db/seeds/production/vereine_musicgest.csv' => 'db/seeds/production' do |task|
  migrator = Migration.new(task.name, 'musicgest10')
  migrator.headers = <<-TEXT.strip_heredoc
    name,email,country,town,zip_code,address,vereinssitz,founding_year,subventionen,type,verband,besetzung,correspondence_language,reported_members,kreis
  TEXT
  migrator.query('societes', <<-SQL.strip_heredoc, <<-CONDITIONS.strip_heredoc)
    CONCAT_WS(' ', nomSociete, nomVilleSoc) AS name,
    NULL AS email,
    NULL AS country,
    nomLocalite AS town,
    cpLocalite AS zip_code,
    adresseSociete AS address,
    nomVilleSoc AS vereinssitz,
    dateFondation AS founding_year,
    subventionCommunale AS subventionen,
    'Group::Verein' AS type,
    CASE societes.mandant
      WHEN 10 THEN 'Kantonaler Musikverband Wallis / Association cantonale des musiques valaisannes'
      WHEN 11 THEN 'Fédération Jurassienne de Musique'
      WHEN 12 THEN 'Société cantonale des musiques vaudoises'
      WHEN 16 THEN 'Société cantonale des musiques fribourgeoises / Freiburger Kantonal-Musikverband'
      WHEN 17 THEN 'Association cantonale des musiques neuchâteloises'
      WHEN 18 THEN 'Association cantonale des musiques genevoises'
    END AS verband,
    NULL AS besetzung,
    NULL AS correspondence_language,
    NULL AS reported_members,
    NULL AS kreis
  SQL
    INNER JOIN localites USING (mandant, autoLocalite)
  CONDITIONS
  migrator.dump('musicgest10') # start-DB
  migrator.dump('music_1_db') # append data from another DB
  migrator.dump('music_2_db') # append data from another DB
end

file 'db/seeds/production/mitglieder.csv' => 'db/seeds/production' do |task|
  migrator = Migration.new(task.name, 'swoffice_sbvnew')
  migrator.headers = <<-TEXT.strip_heredoc
    anrede,first_name,last_name,email,birthday,address,zip_code,town,country,verein_name,verein_ort,eintrittsdatum,bemerkung,zusatz
  TEXT
  migrator.query('tbl_person', <<-SQL.strip_heredoc, <<-CONDITIONS.strip_heredoc)
    NULLIF(tbl_person.anrede, ''),
    tbl_person.vorname,
    tbl_person.name,
    tbl_person.email,
    NULLIF(tbl_person.geburtsdatum, '0000-00-00'),
    tbl_person.strasse,
    tbl_person.plz,
    tbl_person.ort,
    tbl_person.laendercode,
    verein.name,
    verein.domizil,
    NULLIF(tbl_person.eintrittsdatum, '0000-00-00'),
    tbl_person.bemerkung,
    tbl_person.zusatz
  SQL
    INNER JOIN swoffice_sbvnew.tbl_person AS verein ON (tbl_person.parentId = verein.id)
    WHERE tbl_person.typ = 'mitglied' AND tbl_person.aktivmitglied = 1
    AND verein.parentId NOT IN (1577, 1743, 2784, 4729, 4751, 4809)
  CONDITIONS
  migrator.dump
end

file 'db/seeds/production/mitglieder_musicgest.csv' => 'db/seeds/production' do |task|
  migrator = Migration.new(task.name, 'musicgest10')
  migrator.headers = <<-TEXT.strip_heredoc
    anrede,first_name,last_name,email,birthday,address,zip_code,town,country,verein_name,verein_ort,eintrittsdatum,bemerkung,zusatz
  TEXT
  migrator.query('musiciens', <<-SQL.strip_heredoc, <<-CONDITIONS.strip_heredoc)
    CASE autoTitre
      WHEN 1 THEN 'Herr'
      WHEN 2 THEN 'Frau'
      WHEN 3 THEN 'Frau'
    END AS anrede,
    prenomMusicien,
    nomMusicien,
    emailMusicien,
    naissanceMusicien,
    adresseMusicien,
    localites.cpLocalite,
    localites.nomLocalite,
    NULL AS country,
    societes.nomSociete AS vereins_name,
    societes.nomVilleSoc AS vereins_domizil,
    CONCAT(lienmusicienssocietes.anneeEntree, '-01-01') AS eintrittsdatum,
    remarqueMusicien,
    NULL AS zusatz
  SQL
    INNER JOIN localites
      ON (musiciens.mandant = localites.mandant AND musiciens.autoLocalite = localites.autoLocalite)
    LEFT JOIN lienmusicienssocietes
      ON (musiciens.mandant = lienmusicienssocietes.mandant AND musiciens.autoMusicien = lienmusicienssocietes.autoMusicien AND lienmusicienssocietes.anneeSortie = 0)
    LEFT JOIN societes
      ON (lienmusicienssocietes.mandant = societes.mandant AND lienmusicienssocietes.autoSociete = societes.autoSociete)
  CONDITIONS
  migrator.dump('musicgest10') # start-DB
  migrator.dump('music_1_db') # append data from another DB
  migrator.dump('music_2_db') # append data from another DB
end

# imported manually into swoffice_sbvnew with
#
# LOAD DATA LOCAL INFILE './SUISA_SBV_Tarif_B6_Werkdatei_20180710.csv'
#   INTO TABLE werkliste
#   CHARACTER SET 'latin1'
#   FIELDS TERMINATED BY ';' LINES TERMINATED BY '\r\n'
#   (suisaid, title, compositionyear, typ, name);
#
file 'db/seeds/production/suisa_werke.csv' => 'db/seeds/production' do |task|
  migrator = Migration.new(task.name, 'suisa')
  migrator.headers = 'suisa_id,title,composed_by,arranged_by,published_by'
  migrator.query(<<-TABLE.strip_heredoc, <<-FIELDS.strip_heredoc)
    (SELECT
      suisaid                                             AS suisa_id,
      max(title)                                          AS title,
      COUNT(IF(typ IN ('C','CA'), name, NULL))            AS composer_count,
      COUNT(IF(typ = 'AR', name, NULL))                   AS arranger_count,
      COUNT(IF(typ = 'E', name, NULL))                    AS publisher_count,
      GROUP_CONCAT(IF(typ IN ('C','CA','A'), name, NULL)) AS composed_by,
      GROUP_CONCAT(IF(typ = 'AR', name, NULL))            AS arranged_by,
      GROUP_CONCAT(IF(typ = 'E', name, NULL))             AS published_by,
      MAX(IF(typ IN ('C','CA'), name, NULL))              AS composed_by_one,
      MAX(IF(typ = 'AR', name, NULL))                     AS arranged_by_one,
      MAX(IF(typ = 'E', name, NULL))                      AS published_by_one
    FROM werkliste
    where typ in ('C', 'CA', 'AR', 'E', 'A')
    GROUP BY suisaid
    ) AS pivoted_suisa
  TABLE
    suisa_id,
    title,
    IF(composer_count < 3, composed_by, composed_by_one)    AS composed_by,
    IF(arranger_count < 3, arranged_by, arranged_by_one)    AS arranged_by,
    IF(publisher_count < 2, published_by, published_by_one) AS published_by
  FIELDS
  migrator.dump
end

file 'db/seeds/production/suisa_meldungen.csv' => 'db/seeds/production' do |task|
  migrator = Migration.new(task.name, 'swoffice_sbvnew')
  migrator.headers = 'suisa_id,verein_name,verein_ort,datum,count,year'
  migrator.query('tbl_suisameldungen AS m', <<-SQL, <<-CONDITIONS)
    m.id, m.datum, m.title, m.composer, m.editor, m.numbers,
    t.suisaid, t.composed_by, t.arranged_by,
    p.name AS verein, p.domizil,
    m.bookperiod
  SQL
    INNER JOIN tbl_person p ON ( m.person_id = p.id )
    LEFT JOIN (
      SELECT
        suisaid                                             AS suisaid,
        max(title)                                          AS title,
        COUNT(IF(typ IN ('C','CA'), name, NULL))            AS composer_count,
        COUNT(IF(typ = 'AR', name, NULL))                   AS arranger_count,
        COUNT(IF(typ = 'E', name, NULL))                    AS publisher_count,
        GROUP_CONCAT(IF(typ IN ('C','CA','A'), name, NULL)) AS composed_by,
        GROUP_CONCAT(IF(typ = 'AR', name, NULL))            AS arranged_by,
        GROUP_CONCAT(IF(typ = 'E', name, NULL))             AS published_by,
        MAX(IF(typ IN ('C','CA'), name, NULL))              AS composed_by_one,
        MAX(IF(typ = 'AR', name, NULL))                     AS arranged_by_one,
        MAX(IF(typ = 'E', name, NULL))                      AS published_by_one
      FROM suisa.werkliste
      WHERE typ IN ('C', 'CA', 'AR', 'E', 'A')
      GROUP BY suisaid
     ) AS t ON (
       m.title = t.title
     )
     WHERE p.typ = 'verein' AND bookperiod = 2018
  CONDITIONS
  # more join-conditions for m-t
  # -- AND FIND_IN_SET(m.composer, t.composed_by)
  # -- AND FIND_IN_SET(m.editor, t.published_by)
  migrator.dump
end

file 'db/seeds/production/rollen_musicgest.csv' => 'db/seeds/production' do |task|
  migrator = Migration.new(task.name, 'musicgest10')
  migrator.headers = <<-TEXT.strip_heredoc
    first_name,last_name,email,birthday,verein_name,verein_ort,eintrittsdatum,austrittsdatum
  TEXT
  migrator.query('lienmusicienssocietes', <<-SQL.strip_heredoc, <<-CONDITIONS.strip_heredoc)
    prenomMusicien,
    nomMusicien,
    emailMusicien,
    naissanceMusicien,
    societes.nomSociete AS vereins_name,
    societes.nomVilleSoc AS vereins_domizil,
    lienmusicienssocietes.anneeEntree AS role_begin,
    lienmusicienssocietes.anneeSortie AS role_end
  SQL
    LEFT JOIN musiciens ON (lienmusicienssocietes.mandant = musiciens.mandant AND musiciens.autoMusicien = lienmusicienssocietes.autoMusicien)
    LEFT JOIN societes ON (lienmusicienssocietes.mandant = societes.mandant AND lienmusicienssocietes.autoSociete = societes.autoSociete)

    WHERE lienmusicienssocietes.anneeSortie != 0
  CONDITIONS
  migrator.dump('musicgest10') # start-DB
  migrator.dump('music_1_db') # append data from another DB
  migrator.dump('music_2_db') # append data from another DB
end
# rubocop:enable Metrics/BlockLength

class Migration
  include FileUtils

  attr_reader :filename
  attr_writer :headers

  def initialize(filename, database)
    @filename = filename
    @headers  = ''
    @database = database
  end

  def headers
    @headers.chomp
  end

  def tmp_out
    @tmp_out ||= "/var/lib/mysql-files/#{@filename.split('/').last}"
  end

  def query(table = nil, field_sql = '*', condition_sql = '')
    raise ArgumentError, 'Table needs to be passed' if @query.nil? && table.nil?

    @query ||= <<-SQL.strip_heredoc.split("\n").map(&:strip).join(' ').gsub(/\s+/, ' ')
      SELECT #{field_sql}
      INTO OUTFILE '#{tmp_out}'
        CHARACTER SET utf8
        FIELDS TERMINATED BY ','
        OPTIONALLY ENCLOSED BY '\\"'
        LINES TERMINATED BY '\\n'
      FROM #{table}
      #{condition_sql}
    SQL
  end

  def dump(database = @database)
    sh "sudo rm -f #{tmp_out}"
    sh <<-CMD.strip_heredoc
      mysql -u#{ENV['RAILS_DB_USERNAME']} -p#{ENV['RAILS_DB_PASSWORD']} -e \"#{query}\" #{database}
    CMD
    sh "echo '#{headers}' > #{filename}" if database == @database # otherwise only append data
    sh "sudo cat #{tmp_out} >> #{filename}"
    sh "sudo rm -f #{tmp_out}"
  end
end
