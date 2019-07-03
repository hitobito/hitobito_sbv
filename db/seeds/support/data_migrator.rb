# encoding: utf-8

#  Copyright (c) 2018 - 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

# Support for better readable migration/seed-files
class DataMigrator

  def initialize(fn = nil)
    @import_date = Time.zone.now

    @mitglieder_ids = {}
    @musicgest = fn.to_s.match(/musicgest/)
  end

  def vereine
    @vereine ||= Group.pluck(:name, :id).to_h
  end

  def musicgest?
    @musicgest
  end

  def parse_date(string, default: @import_date, lower_limit: 1900)
    date = Date.parse(string)
    date.to_s if date.year > lower_limit
  rescue ArgumentError, TypeError
    default
  end

  def infer_verein(vereins_name, vereins_ort, vereins_typ = nil)
    vereins_name = [vereins_name, vereins_ort].join(' ')
    verband_name = vereins_name

    vereins_id = [vereine[vereins_name], vereine[verband_name]].compact.first

    return vereins_id if vereins_typ.nil?

    mitglieder_verein(vereins_is, vereins_typ)
  end

  def mitglieder_verein(vereins_id, vereins_typ)
    if vereins_id
      @mitglieder_ids[vereins_id] ||= load_verein(vereins_id, vereins_typ)
    else
      nil
    end
  end

  def load_verein(vereins_id, vereins_typ = 'Mitglieder')
    Group.find(vereins_id).children.where(name: vereins_typ).pluck(:id).first
  end

  def load_person(person_data, birthday_default: nil, lower_limit: 1900)
    if person_data['email'].present?
      Person.find_by(email: person_data['email'])
    else
      Person.find_by(
        first_name: person_data['first_name'],
        last_name:  person_data['last_name'],
        birthday:   parse_date(
          person_data['birthday'],
          default: birthday_default,
          lower_limit: lower_limit
        ),
      )
    end
  end

end
