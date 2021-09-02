# frozen_string_literal: true

#  Copyright (c) 2021, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'
migration_file_name = Dir[Wagons.find('sbv').root.join('db/migrate/*_add_correspondence_language_to_person_by_layer.rb')].first
require migration_file_name

describe AddCorrespondenceLanguageToPersonByLayer do

  let(:migration) { described_class.new.tap { |m| m.verbose = false } }
  let(:person) { people(:leader) }
  let(:group) { people(:leader).primary_group }

  context 'up' do
    before do
      migration.migrate(:down)
    end

    it 'does not set default language of person if layer has no language' do
      adjust_person(true)
      adjust_group(false)

      # Expect correspondence values to be unchanged
      expect(person.correspondence_language).to eq('it')
      expect(group.correspondence_language).to eq(nil)

      # Execute migration
      migration.up

      # Update person
      person.reload

      # Expect person languages to be unchanged after migration
      expect(person.correspondence_language).to eq('it')
      expect(group.correspondence_language).to eq(nil)
    end

    it 'does not set default language if person already has correspondence language' do
      adjust_person(true)
      adjust_group(true)

      # Expect person to have language already
      expect(person.correspondence_language).to eq("it")
      expect(group.correspondence_language).to eq("fr")

      # Execute migration
      migration.up

      # Update person
      person.reload

      # Expect person with language to be unchanged
      expect(person.correspondence_language).to eq("it")
      expect(group.correspondence_language).to eq("fr")
    end

    it 'does set default language from layer if person has no language' do
      adjust_person(false)
      adjust_group(true)

      # Expect Person to have no language
      expect(person.correspondence_language).to eq(nil)
      expect(group.correspondence_language).to eq('fr')

      # Execute migration
      migration.up

      # Update person
      person.reload

      # Expect person to have default language set
      expect(group.correspondence_language).to eq('fr')
      expect(person.correspondence_language).to eq('fr')
    end

    it 'does not update language if layer and person languages are nil' do
      adjust_person(false)
      adjust_group(false)

      # Expect Person to have no language
      expect(person.correspondence_language).to eq(nil)
      expect(group.correspondence_language).to eq(nil)

      # Execute migration
      migration.up

      # Update person
      person.reload

      # Expect person and group to not have language
      expect(person.correspondence_language).to eq(nil)
      expect(group.correspondence_language).to eq(nil)
    end

    it 'covers each case in one test' do
      # Fabricate groups with and without language
      group_with_language = Fabricate(:group, { correspondence_language: "de", type: "Group::Verein" })
      group_without_language = Fabricate(:group, { correspondence_language: nil, type: "Group::Verein" })

      # Fabricate people with or without self or layer language
      person_with_layer_and_own_language = fabricate_person(true, group_with_language)
      person_without_own_but_layer_language = fabricate_person(false , group_with_language)
      person_with_but_layer_without_language = fabricate_person(true, group_without_language)
      person_and_layer_without_language = fabricate_person(false , group_without_language)

      # Expect people and groups to be fabricated as planned
      expect(person_with_layer_and_own_language.correspondence_language).to eq("it")
      expect(person_with_layer_and_own_language.primary_group.correspondence_language).to eq("de")
      expect(person_without_own_but_layer_language.correspondence_language).to eq(nil)
      expect(person_without_own_but_layer_language.primary_group.correspondence_language).to eq("de")
      expect(person_with_but_layer_without_language.correspondence_language).to eq("it")
      expect(person_with_but_layer_without_language.primary_group.correspondence_language).to eq(nil)
      expect(person_and_layer_without_language.correspondence_language).to eq(nil)
      expect(person_and_layer_without_language.primary_group.correspondence_language).to eq(nil)

      # Run migration
      migration.up

      # Update people
      person_with_layer_and_own_language.reload
      person_without_own_but_layer_language.reload
      person_with_but_layer_without_language.reload
      person_and_layer_without_language.reload

      # Expect no change here as person and group already have a language
      expect(person_with_layer_and_own_language.correspondence_language).to eq("it")
      expect(person_with_layer_and_own_language.primary_group.correspondence_language).to eq("de")

      # Expect this case to update the person language according the layers one
      expect(person_without_own_but_layer_language.correspondence_language).to eq("de")
      expect(person_without_own_but_layer_language.primary_group.correspondence_language).to eq("de")

      # Expect language from person not to be overwritten by nil from the layer language
      expect(person_with_but_layer_without_language.correspondence_language).to eq("it")
      expect(person_with_but_layer_without_language.primary_group.correspondence_language).to eq(nil)

      # Expect nothing to change when neither layer nor person have languages
      expect(person_and_layer_without_language.correspondence_language).to eq(nil)
      expect(person_and_layer_without_language.primary_group.correspondence_language).to eq(nil)
    end
  end

  private

  def adjust_person(with_language)
    person.update_attribute(:correspondence_language, with_language ? 'it' : nil)
    person.save!(validate: false)
  end

  def adjust_group(with_language)
    group.update_attribute(:correspondence_language, with_language ? "fr" : nil)
    group.save!(validate: false)
  end

  def fabricate_person(with_language, group)
    person = Fabricate(:person, {
      correspondence_language: "it",
      primary_group: group
    })

    unless with_language
      person.update_attribute(:correspondence_language, nil)
    end

    person.save!(validate: false)
    person
  end
end