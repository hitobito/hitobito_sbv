# frozen_string_literal: true

require 'spec_helper'

migration_file_name = Dir[Wagons.find('sbv').root.join('db/migrate/*_add_correspondence_language_to_person_by_layer.rb')].first
require migration_file_name

describe AddCorrespondenceLanguageToPersonByLayer do

  let(:migration) { described_class.new.tap { |m| m.verbose = false } }
  let(:group_without_language) { Fabricate(:group, { correspondence_language: nil, type: "Group::Verein" }) }
  let(:group_with_language) { Fabricate(:group, { correspondence_language: "fr", type: "Group::Verein" }) }
  let(:person_with_language) { Fabricate(:person, { correspondence_language: "it", primary_group: group_with_language }) }
  let(:person_without_language) { Fabricate(:person, { correspondence_language: nil, primary_group: group_without_language }) }

  before(:all) { self.use_transactional_tests = false }
  after(:all)  { self.use_transactional_tests = true }

  context 'up' do
    before {
      migration.down
    }

    it 'does not set default language of person if layer has no language' do
      # Expect correspondence values to be unchanged
      expect(person_without_language.correspondence_language).to eq('it')
      expect(group_without_language.correspondence_language).to be(nil)

      # Execute migration
      migration.up

      # Expect person languages to be unchanged after migration
      expect(person_without_language.correspondence_language).to eq('it')
      expect(group_without_language.correspondence_language).to be(nil)
    end

    it 'does not set default language if person already has correspondence language' do
      # Expect person to have language already
      expect(person_with_language.correspondence_language).to eq('it')
      expect(group_without_language.correspondence_language).to be(nil)

      # Execute migration
      migration.up

      # Expect person with language to be unchanged
      expect(person_with_language.correspondence_language).to eq('it')
      expect(group_without_language.correspondence_language).to be(nil)
    end

    it 'does set default language from layer if person has no language' do
      # Set layer with language to person without
      person_without_language.primary_group = group_with_language

      # Expect Person to have no language
      expect(person_without_language.correspondence_language).to eq(nil)
      expect(group_with_language.correspondence_language).to eq('fr')
      
      # Execute migration
      migration.up

      # Expect person to have default language set
      expect(person_without_language.correspondence_language).to eq('fr')
      expect(group_with_language.correspondence_language).to eq('fr')
    end
  end
end