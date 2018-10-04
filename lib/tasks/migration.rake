namespace :migration do
  task :clean do
    rm_f 'db/seeds/production/verbaende.csv'
    rm_f 'db/seeds/production/vereine.csv'
    rm_f 'db/seeds/production/mitglieder.csv'
    # rm_f 'db/seeds/production/chargen.csv'
  end

  task extract: [
    'db/seeds/production/verbaende.csv',
    'db/seeds/production/vereine.csv',
    'db/seeds/production/mitglieder.csv',
    # 'db/seeds/production/chargen.csv',
  ]
end

directory 'db/seeds/production'

file 'db/seeds/production/verbaende.csv' => 'db/seeds/production' do |task|
  migrator = Migration.new(task.name)
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
  migrator = Migration.new(task.name)
  migrator.headers = <<-TEXT.strip_heredoc
    name,email,country,town,zip_code,address,vereinssitz,founding_year,subventionen,type,verband,besetzung,correspondence_language,reported_members,kreis
  TEXT
  migrator.query('tbl_person', <<-SQL.strip_heredoc, <<-CONDITIONS.strip_heredoc)
    CONCAT(tbl_person.name, ' ', tbl_person.domizil) AS name,
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
  CONDITIONS
  # faxGeschaeft, faxPrivat, telGeschaeft, homepage, hinweis, zusatz, konto, kreisverbaende,
  migrator.dump
end

file 'db/seeds/production/mitglieder.csv' => 'db/seeds/production' do |task|
  migrator = Migration.new(task.name)
  migrator.headers = <<-TEXT.strip_heredoc
    anrede,first_name,last_name,email,birthday,address,zip_code,town,country,verein_name,verein_ort,bemerkung,zusatz
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
    tbl_person.bemerkung,
    tbl_person.zusatz
  SQL
    INNER JOIN swoffice_sbvnew.tbl_person AS verein ON (tbl_person.parentId = verein.id)
    WHERE tbl_person.typ = 'mitglied' AND tbl_person.aktivmitglied = 1
  CONDITIONS
  migrator.dump
end

class Migration
  include FileUtils

  attr_reader :filename
  attr_writer :headers

  def initialize(filename)
    @filename = filename
    @headers  = ''
  end

  def headers
    @headers.chomp
  end

  def tmp_out
    @tmp_out ||= "/var/lib/mysql-files/#{@filename.split('/').last}"
  end

  def query(table = nil, field_sql = '*', condition_sql = '')
    raise ArgumentError, 'Table needs to be passed' if @query.nil? && table.nil?

    @query ||= <<-SQL.strip_heredoc.split("\n").map(&:strip).join(' ')
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

  def dump
    sh "sudo rm -f #{tmp_out}"
    sh <<-CMD.strip_heredoc
      mysql -u#{ENV['RAILS_DB_USERNAME']} -p#{ENV['RAILS_DB_PASSWORD']} -e \"#{query}\" swoffice_sbvnew
    CMD
    sh "echo '#{headers}' > #{filename}"
    sh "sudo cat #{tmp_out} >> #{filename}"
    sh "sudo rm -f #{tmp_out}"
  end
end
