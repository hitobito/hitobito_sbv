# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv
  module Instruments
    module I18nBackendExtension
      def reload!(...)
        super.tap { Catalog.register_i18n! }
      end
    end
  end
end

Rails.application.config.to_prepare do
  Sbv::Instruments::Catalog.register_i18n!
end

Rails.application.config.after_initialize do
  Sbv::Instruments::Catalog.register_i18n!

  backend = I18n.backend
  next unless backend.respond_to?(:reload!)

  unless backend.singleton_class.included_modules.include?(Sbv::Instruments::I18nBackendExtension)
    backend.singleton_class.prepend(Sbv::Instruments::I18nBackendExtension)
  end
end
