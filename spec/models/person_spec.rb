# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe Person do

  let(:person) { people(:member) }

  %w(first_name last_name birthday).each do |attr|
    it "validates presence of #{attr}" do
      person.update_attribute(attr, '')
      translated_attr = Person.human_attribute_name(attr)

      expect(person).not_to be_valid
      expect(person.errors.full_messages).
        to include("#{translated_attr} muss ausgefüllt werden")
    end
  end

end
