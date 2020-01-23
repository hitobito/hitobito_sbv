#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe Group do

  include_examples 'group types'
  let(:group) { groups(:kontakte_5) }

  context 'hostname' do
    it 'is nullfied when blank' do
      expect(group.update(hostname: ''))
      expect(group.reload.hostname).to eq nil
    end

    it 'is validated to not have a schema' do
      group.hostname = 'https://example.com'

      expect(group).to_not be_valid
    end

    it 'is downcased' do
      group.update(hostname: 'EXAMPLE.COM')

      expect(group.reload.hostname).to eq 'example.com'
    end
  end

  context '#hostname_from_hierarchy' do
    subject { group.hostname_from_hierarchy }

    it 'might be nil' do
      expect(subject).to be_nil
    end

    it 'might read hostname from group' do
      group.update(hostname: 'example.com')
      expect(subject).to eq 'example.com'
    end

    it 'might read hostname from hierarchy' do
      group.parent.update(hostname: 'example.com')
      expect(subject).to eq 'example.com'
    end
  end

  context '#song_counts' do
    subject { groups(:hauptgruppe_1) }

    it 'is a scope' do
      expect(subject.song_counts).to be_a ActiveRecord::Relation
    end

    it 'contains several song_counts' do
      expect(subject.song_counts.count).to be 3
    end

    it 'does not include deleted groups' do
      expect(song_counts(:mama_count).concert.verein).to be_deleted

      expect(subject.song_counts).to_not include song_counts(:mama_count)
    end
  end

end
