#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'spec_helper'

describe Person::LoginMailer do

  it 'populates dachverband placeholder' do
    content = CustomContent.new(key: Person::LoginMailer::CONTENT_LOGIN,
                                placeholders_required: 'login-url',
                                placeholders_optional: 'recipient-name, sender-name, dachverband')
    content.save(validate: false)

    CustomContent::Translation.create!(custom_content_id: content.id,
                                       locale: 'de',
                                       label: 'Login senden',
                                       subject: "Willkommen bei #{Settings.application.name}",
                                       body: "Hallo {recipient-name}<br/><br/>Dein {dachverband}")




    mail = Person::LoginMailer.login(people(:member),
                                     people(:leader),
                                     'abcdef')

    expect(mail.body).to match /Dein Hauptgruppe/
  end

end
