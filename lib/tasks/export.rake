# encoding: utf-8

#  Copyright (c) 2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

namespace :export do
  desc 'Export all members'
  task members: [:environment] do
    dachverband = Group.find(1)

    extractor = DataExtraction.new('tmp/all-members.csv', ENV['RAILS_DB_NAME'])
    extractor.headers = 'vorname,nachname,hauptgruppe,email'

    extractor.query('people', <<-FIELD_SQL, <<-CONDITION_SQL)
      people.first_name,
      people.last_name,
      layer_groups.name AS primary_group,
      people.email
    FIELD_SQL
      INNER JOIN groups ON groups.id = people.primary_group_id
      INNER JOIN groups AS layer_groups ON layer_groups.id = groups.layer_group_id
      WHERE people.id IN (#{Role.where(group: dachverband.descendants).select(:person_id).uniq.to_sql.delete('`')})
    CONDITION_SQL

    extractor.dump
  end
end
