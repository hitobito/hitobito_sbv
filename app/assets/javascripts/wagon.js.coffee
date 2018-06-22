- #  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
- #  hitobito_sbv and licensed under the Affero General Public License version 3
- #  or later. See the COPYING file at the top-level directory or at
- #  https://github.com/hitobito/hitobito_sbv.


app = window.App ||= {}

app.Songs = {
  update: (e) ->
    song = JSON.parse(e)
    $("form.new_song_count :input[name='song_count[song_id]']").val(song.id)
    $("form.new_song_count").submit()
}
