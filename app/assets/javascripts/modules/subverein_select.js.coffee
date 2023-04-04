app = window.App ||= {}

app.SubvereinSelect = {
  select_all: (e) ->
    checked = e.target.checked
    table = $(e.target).closest('.checkboxes')
    table.find('input[type="checkbox"]').prop('checked', checked)
}

$(document).on('click', '#subgroup-select .checkboxes input#all', app.SubvereinSelect.select_all)
