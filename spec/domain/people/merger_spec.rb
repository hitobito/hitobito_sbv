# frozen_string_literal: true

require "spec_helper"

describe People::Merger do
  let(:person) { Fabricate(:person) }
  let(:duplicate) { Fabricate(:person_with_address_and_phone) }
  let(:actor) { people(:admin) }
  let(:person_roles) { person.roles.with_deleted }

  let(:merger) { described_class.new(@source.reload, @target.reload, actor) }

  before do
    Fabricate("Group::RootMusikkommission::Mitglied",
      group: groups(:musikkommission_4),
      person: duplicate,
      created_at: 5.seconds.ago,
      deleted_at: Time.zone.now)
  end

  context "merge people" do
    it "merges roles and considers created_at validations" do
      @source = duplicate
      @target = person

      expect do
        merger.merge!
      end.to change(Person, :count).by(-1)

      person.reload

      expect(person_roles.count).to eq(1)
      group_ids = person_roles.map(&:group_id)
      expect(group_ids).to include(groups(:musikkommission_4).id)

      expect(Person.where(id: duplicate.id)).not_to exist
    end
  end
end
