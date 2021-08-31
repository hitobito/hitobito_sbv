# frozen_string_literal: true

require 'spec_helper'

migration_file_name = Dir[Wagons.find('sbv').root.join('db/migrate/*_add_correspondence_language_to_person_by_layer.rb')].first
require migration_file_name

describe AddCorrespondenceLanguageToPersonByLayer do

  let(:migration) { described_class.new.tap { |m| m.verbose = false } }
  let!(:group_without_language) { Fabricate(:group, { correspondence_language: nil, type: "Group::Verein" }) }
  let!(:group_with_language) { Fabricate(:group, { correspondence_language: "fr", type: "Group::Verein" }) }

  before(:all) { self.use_transactional_tests = false }
  after(:all)  { self.use_transactional_tests = true }

  context 'up' do
    before {
      migration.down
    }

    it 'does not set default language of person if layer has no language' do
      person = fabricate_person(true, false)
      group = person.primary_group

      # Expect correspondence values to be unchanged
      expect(person.correspondence_language).to eq('it')
      expect(group.correspondence_language).to eq(nil)

      # Execute migration
      migration.up

      # Expect person languages to be unchanged after migration
      expect(person.correspondence_language).to eq('it')
      expect(group.correspondence_language).to eq(nil)
    end

    it 'does not set default language if person already has correspondence language' do
      person = fabricate_person(true, true)
      group = person.primary_group

      # Expect person to have language already
      expect(person.correspondence_language).to eq("it")
      expect(group.correspondence_language).to eq("fr")

      # Execute migration
      migration.up

      # Expect person with language to be unchanged
      expect(person.correspondence_language).to eq("it")
      expect(group.correspondence_language).to eq("fr")
    end

    it 'does set default language from layer if person has no language' do
      person = fabricate_person(false, true)
      group = person.primary_group

      # Expect Person to have no language
      expect(person.correspondence_language).to eq(nil)
      expect(group.correspondence_language).to eq('fr')

      # Execute migration
      migration.up

      # Expect person to have default language set
      expect(person.correspondence_language).to eq('fr')
      expect(group.correspondence_language).to eq('fr')
    end

    it 'does not update language if layer and person languages are nil' do
      person = fabricate_person(false, false)
      group = person.primary_group

      # Expect Person to have no language
      expect(person.correspondence_language).to eq(nil)
      expect(group.correspondence_language).to eq(nil)

      # Execute migration
      migration.up

      # Expect person and group to not have language
      expect(person.correspondence_language).to eq(nil)
      expect(group.correspondence_language).to eq(nil)
    end
  end

  private

  def fabricate_person(with_language, layer_has_language)
    person = Fabricate(:person, {
      correspondence_language: "it",
      primary_group: layer_has_language ? group_with_language : group_without_language
    })

    unless with_language
      person.update_attribute(:correspondence_language, nil)
    end

    person.save!(validate: false)
    person
  end
end