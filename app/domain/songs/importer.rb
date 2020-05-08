# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'csv'

class Songs::Importer
  attr_accessor :filepath

  def initialize(filepath)
    @filepath = filepath
  end

  def compose
    return 'File not found' unless File.exist?(filepath)

    csv_rows = CSV.read(filepath).drop(1)
    ActiveRecord::Base.connection.execute(insert_songs_statement(csv_rows))
    task_done_output(csv_rows.count)
  end

  private

  def task_done_output(count)
    "\n=============== DONE ===============" \
    "\nSuccessfully inserted #{count} songs" \
    "\n====================================\n"
  end

  def insert_songs_statement(rows)
    <<-SQL
      INSERT INTO songs(title, composed_by, arranged_by)
      VALUES #{values(rows).join(',')}
    SQL
  end

  def values(rows)
    rows.collect do |title, composed_by, arranged_by|
      "(#{ActiveRecord::Base.connection.quote(title)},"\
        " #{ActiveRecord::Base.connection.quote(composed_by)},"\
        " #{ActiveRecord::Base.connection.quote(arranged_by)})"
    end
  end
end
