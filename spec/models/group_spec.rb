# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe Group do

  include_examples 'group types'
  let(:group) { groups(:kontakte_5) }

  it 'nullifies blank hostname' do
    expect(group.update(hostname: ''))
    expect(group.reload.hostname).to eq nil
  end

  context '#hostname_from_hierarchy' do
    subject { group.hostname_from_hierarchy }

    it '#hostname_from_hierarchy might be nil' do
      expect(subject).to be_nil
    end

    it '#hostname_from_hierarchy might read hostname from group' do
      group.update(hostname: 'example.com')
      expect(subject).to eq 'example.com'
    end

    it '#hostname_from_hierarchy might read hostname from hierarchy' do
      group.parent.update(hostname: 'example.com')
      expect(subject).to eq 'example.com'
    end
  end

end
