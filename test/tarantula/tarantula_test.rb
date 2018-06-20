# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require 'test_helper'
require 'relevance/tarantula'
require 'tarantula/tarantula_config'

class TarantulaTest < ActionDispatch::IntegrationTest
  # Load enough test data to ensure that there's a link to every page in your
  # application. Doing so allows Tarantula to follow those links and crawl
  # every page.  For many applications, you can load a decent data set by
  # loading all fixtures.

  reset_fixture_path File.expand_path('../../../spec/fixtures', __FILE__)

  include TarantulaConfig

  # Crawls the application with admin permissions
  # to cover as many actions as possible.
  def test_tarantula_as_admin
    crawl_as(people(:admin))
  end

  private

  def configure_urls_with_hitobito_sbv(t, person)
    configure_urls_without_hitobito_sbv(t, person)

    # Wagon specific urls configuration here
  end
  alias_method_chain :configure_urls, :hitobito_sbv

end
