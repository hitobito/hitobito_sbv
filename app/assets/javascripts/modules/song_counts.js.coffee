- #  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
- #  hitobito_sbv and licensed under the Affero General Public License version 3
- #  or later. See the COPYING file at the top-level directory or at
- #  https://github.com/hitobito/hitobito_sbv.#song_counts_typeahead

app = window.App ||= {}

app.SongCounts = {
  update: (e) ->
    song = JSON.parse(e)

    if song.id
      $("form.new_song_count :input[name='song_count[song_id]']").val(song.id)
      $("form.new_song_count").submit()
      song.label
    else
      $('form#new_song').show().find('#song_title').focus()

    $(":input[data-updater='Songs.update']")[0].value = ''

  add: (e) ->
    song = JSON.parse(e)

    unless song.id
      $('form#new_song').show().find('#song_title').focus()
      return

    exisiting_songs = $("#song_counts_fields .song_id:input[value='#{song.id}']")
    if exisiting_songs.length > 0
      app.SongCounts.incExistingCount(exisiting_songs[0])
      return

    app.SongCounts.new(song)

    $(":input[data-updater='SongCounts.add']")[0].value = ''

  new: (song) ->
    $('.add_nested_fields').first().click() # add new lineitem
    fields = $('#song_counts_fields .fields').last().find('input, label')
    fields.each (idx, elm) ->
      if elm.name
        name = elm.name.match(/\d\]\[(.*)\]$/)[1]
        elm.value = song[name] if song[name]
        elm.value = song.id if name == 'song_id'
      else
        $(elm).append($(app.SongCounts.formattedTitle(song)))
    fields = $('#song_counts_fields .fields').last()
    app.SongCounts.highlight(fields)

  formattedTitle: (song) ->
    "<strong>#{song.title}</strong> " +
    "<span class='muted'>#{song.composed_by} | " +
    "#{song.arranged_by} | " +
    "#{song.published_by}</span>"

  incExistingCount: (elm) ->
    fields = $(elm).closest('.fields')
    fields.find('.inc_song_count').trigger('click')
    app.SongCounts.highlight(fields)

  highlight: (elm) ->
    elm.prependTo('#song_counts_fields')
    elm.effect('highlight', {}, 3000)

  inc: (e) ->
    app.SongCounts.changeCount(e, +1)

  dec: (e) ->
    app.SongCounts.changeCount(e, -1)

  changeCount: (e, action) ->
    counter = $(e.target).closest('.count').find('input')
    count = parseInt(counter.val()) + action
    counter.val(count)
    counter.trigger('change')
    false

  validate: (e) ->
    elm = $(e.target)
    count = parseInt(elm.val())
    elm.val(30) if  count > 30
    elm.val(0) if count < 0

}

$(document).on('click', '.inc_song_count', app.SongCounts.inc)
$(document).on('click', '.dec_song_count', app.SongCounts.dec)
$(document).on('change', '.count input', app.SongCounts.validate)
