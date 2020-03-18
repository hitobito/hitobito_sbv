# frozen_string_literal: true

#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class DataExtraction
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

    @query = <<-SQL.strip_heredoc.split("\n").map(&:strip).join(' ').gsub(/\s+/, ' ')
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

  def show_query
    puts @query.gsub(/INTO OUTFILE.*FROM/, 'FROM') # rubocop:disable Rails/Output
  end

  def dump
    start_csv
    append(@database)
  end

  def append(database = @database)
    fetch(database)
    append_data
  end

  private

  def fetch(database = @database)
    unless @query
      raise "No Query set, please use #{self.class.name}#query(table, fields, joins) to set one"
    end

    sh "sudo rm -f #{tmp_out}"
    sh <<-CMD.strip_heredoc
      mysql -u#{ENV['RAILS_DB_USERNAME']} -p#{ENV['RAILS_DB_PASSWORD']} -e \"#{@query}\" #{database}
    CMD
  end

  def start_csv
    sh "echo '#{headers}' > #{filename}"
  end

  def append_data
    sh "sudo cat #{tmp_out} >> #{filename}"
    sh "sudo rm -f #{tmp_out}"
  end
end
