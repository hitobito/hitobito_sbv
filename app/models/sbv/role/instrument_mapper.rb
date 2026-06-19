# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::Role::InstrumentMapper
  module_function

  def map(raw_value)
    Sbv::Instruments::Catalog.map(raw_value)
  end
end
