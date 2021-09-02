# frozen_string_literal: true

#  Copyright (c) 2021, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class AddCorrespondenceLanguageToPersonByLayer < ActiveRecord::Migration[6.0]
  def up
    people_without_language.find_each do |person|
      person.correspondence_language = person.primary_group.correspondence_language
      person.save
    end
  end

  private

  def people_without_language
    supported_languages = Settings.application.correspondence_languages.to_h.keys.map(&:to_s)
    Person.where("people.correspondence_language NOT IN (?) OR people.correspondence_language IS NULL", supported_languages)
  end

end
