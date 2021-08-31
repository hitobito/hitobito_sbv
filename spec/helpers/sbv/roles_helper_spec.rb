# frozen_string_literal: true

#  Copyright (c) 2021, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe Sbv::RolesHelper do
  describe '#default_language_for_person' do
    let(:group)   { groups(:hauptgruppe_1)}

    it 'returns predefined language for group if preset' do
      group.correspondence_language = "de"
      language = default_language_for_person(group)

      expect(language).to eq("de")
    end

    it 'returns predefined languages if language not set' do
      group.correspondence_language = nil
      language = default_language_for_person(group)

      expect(language).to eq(["Deutsch", :de])
    end
  end
end
