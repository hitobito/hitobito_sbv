#  Copyright (c) 2012-2019, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

Group::Generalverband.seed_once(:name, name: 'hitobito', parent_id: nil)

superstructure = Group::Generalverband.first

Group::Root.seed_once(:parent_id, name: 'Hauptgruppe', parent_id: superstructure.id)
