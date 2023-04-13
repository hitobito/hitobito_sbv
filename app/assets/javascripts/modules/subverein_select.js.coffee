- #  Copyright (c) 2023, Schweizer Blasmusikverband. This file is part of
- #  hitobito_sbv and licensed under the Affero General Public License version 3
- #  or later. See the COPYING file at the top-level directory or at
- #  https://github.com/hitobito/hitobito_sbv.

app = window.App ||= {}

app.SubvereinSelect = {
  select_all: (e) ->
    checked = e.target.checked
    table = $(e.target).closest('.checkboxes')
    table.find('input[type="checkbox"]:not([disabled])').prop('checked', checked)
}

$(document).on('click', '#subgroup-select .checkboxes input#all', app.SubvereinSelect.select_all)
