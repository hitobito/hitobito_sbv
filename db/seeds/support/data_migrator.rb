# encoding: utf-8

#  Copyright (c) 2018 - 2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

# Support for better readable migration/seed-files
class DataMigrator

  def initialize(fn = nil)
    @import_date = Time.zone.now

    @vereine = Group.pluck(:name, :id).to_h
    @mitglieder_ids = {}
    @musicgest = fn.to_s.match(/musicgest/)
  end

  def musicgest?
    @musicgest
  end

  def parse_date(string, default: @import_date)
    date = Date.parse(string)
    date.to_s if date.year > 1900
  rescue ArgumentError, TypeError
    default
  end

  def infer_verein(vereins_name, vereins_ort, vereins_typ = nil)
    vereins_name = [vereins_name, vereins_ort].join(' ')
    verband_name = vereins_name

    vereins_id = [@vereine[vereins_name], @vereine[verband_name]].compact.first

    return vereins_id if vereins_typ.nil?

    if vereins_id
      @mitglieder_ids[vereins_id] ||= load_verein(vereins_id, vereins_typ)
    else
      nil
    end
  end

  def load_verein(vereins_id, vereins_typ = 'Mitglieder')
    Group.find(vereins_id).children.where(name: vereins_typ).pluck(:id).first
  end

end
