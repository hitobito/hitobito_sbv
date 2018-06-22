# encoding: utf-8

#  Copyright (c) 2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe SongAbility do

  subject { ability }

  let(:ability) { Ability.new(role.person.reload) }
  let(:verein)  { groups(:musikgesellschaft_alterswil_35) }

  [
  %w(Group::Verein::Admin musikgesellschaft_alterswil_35),
  %w(Group::VereinMitglieder::Mitglied mitglieder_43)
  ].each do |role, group|
    context role do
    let(:role) { Fabricate(role.to_sym, group: groups(group)) }

      %w(Song SongCensus).each do |model|
        it "may not index #{model}" do
          is_expected.not_to be_able_to(:index, model.constantize)
        end

        it "may not manage #{model}" do
          is_expected.not_to be_able_to(:manage, model.constantize)
        end
      end

      context 'in own group' do
        let(:song_count)  { SongCount.new(verein: verein) }
   
        if role.match(/Mitglied$/)
          it 'may not read on song_count' do
            is_expected.not_to be_able_to(:read, song_count)
          end
        else
          it 'may read on song_count' do
            is_expected.to be_able_to(:read, song_count)
          end
        end
      end
    end
  end

  context 'suisa_admin' do
    let(:role) { Fabricate(Group::Verein::SuisaAdmin.name.to_sym, group: verein) }

    %w(Song SongCount SongCensus).each do |model|
      it "may index #{model}" do
        is_expected.to be_able_to(:index, model.constantize)
      end

      it "may manage #{model}" do
        is_expected.to be_able_to(:manage, model.constantize)
      end
    end
  end
end
