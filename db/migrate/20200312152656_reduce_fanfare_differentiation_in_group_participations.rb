class ReduceFanfareDifferentiationInGroupParticipations < ActiveRecord::Migration
  def up
    say_with_time 'Mapping Fanfare Benelux' do
      execute <<-SQL.strip_heredoc.split.join(' ')
        UPDATE event_group_participations
        SET music_type = 'fanfare_benelux'
        WHERE music_type IN ('fanfare_benelux_harmony', 'fanfare_benelux_brass_band')
      SQL
    end

    say_with_time 'Mapping Fanfare Mixte' do
      execute <<-SQL.strip_heredoc.split.join(' ')
        UPDATE event_group_participations
        SET music_type = 'fanfare_mixte'
        WHERE music_type IN ('fanfare_mixte_harmony', 'fanfare_mixte_brass_band')
      SQL
    end
  end

  def down
    say_with_time 'Mapping Fanfare Benelux' do
      execute <<-SQL.strip_heredoc.split.join(' ')
        UPDATE event_group_participations
        SET music_type = 'fanfare_benelux_harmony'
        WHERE music_type = 'fanfare_benelux'
      SQL
    end

    say_with_time 'Mapping Fanfare Mixte' do
      execute <<-SQL.strip_heredoc.split.join(' ')
        UPDATE event_group_participations
        SET music_type = 'fanfare_mixte_harmony'
        WHERE music_type = 'fanfare_benelux'
      SQL
    end
  end
end
