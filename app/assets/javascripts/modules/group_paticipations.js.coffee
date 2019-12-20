app = window.App ||= {}

app.GroupParticipations = {
  load_music_levels: (e) ->
    elem = $(e.target)
    music_style = elem.val()
    console.log(music_style)
    options = $("." + music_style).html()
    console.log(options)
    $('#event_group_participation_music_level').html(options)
}

$(document).on('change', '#event_group_participation_music_type',app.GroupParticipations.load_music_levels)
