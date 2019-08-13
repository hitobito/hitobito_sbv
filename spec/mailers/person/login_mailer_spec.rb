#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe Person::LoginMailer do

  before do

    content = CustomContent.new(key: Person::LoginMailer::CONTENT_LOGIN,
                                placeholders_required: 'login-url',
                                placeholders_optional: 'recipient-name, sender-name, dachverband')
    content.save(validate: false)

    CustomContent::Translation.create!(custom_content_id: content.id,
                                       locale: 'de',
                                       label: 'Login senden',
                                       subject: "Willkommen bei #{Settings.application.name}",
                                       body: body)

  end

  let(:mail) { Person::LoginMailer.login(people(:member), people(:leader), 'abcdef') }
  let(:body) { 'Hallo' }

  context 'placeholders' do
    let(:body) { "Hallo {recipient-name}<br/><br/>Dein {dachverband}" }

    subject { mail.body }

    it 'populates dachverband placeholder' do
      expect(subject).to match /Dein Hauptgruppe/
    end
  end

  context '#return_path' do
    subject { mail.return_path.split('@').last }
    it 'defaults to localhost domain' do
      expect(subject).to eq 'localhost'
    end

    it 'reads hostname from top_level group' do
      people(:leader).primary_group.update(hostname: 'example.com')
      expect(subject).to eq 'example.com'
    end
  end
end
