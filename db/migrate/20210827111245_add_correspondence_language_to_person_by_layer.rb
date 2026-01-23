# frozen_string_literal: true

#  Copyright (c) 2021, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class AddCorrespondenceLanguageToPersonByLayer < ActiveRecord::Migration[6.0]
  def up
    people = people_without_language
    say_with_time('updating people to have default language set') do
      people.find_each do |person_without_language|
        next unless person_without_language.primary_group&.correspondence_language

        person_without_language.correspondence_language = person_without_language.primary_group.correspondence_language
        person_without_language.save
      end
    end
  end

  private

  def people_without_language
    say_with_time('gathering people who do not have a language set') do
      supported_languages = Settings.application.languages.to_hash.merge(Settings.application.additional_languages&.to_hash || {}).keys.map(&:to_s)
      Person.where("people.correspondence_language NOT IN (?) OR people.correspondence_language IS NULL", supported_languages)
    end
  end

end
