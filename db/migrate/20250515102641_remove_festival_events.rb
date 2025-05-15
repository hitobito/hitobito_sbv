class RemoveFestivalEvents < ActiveRecord::Migration[7.1]
  def up
    execute "DELETE FROM events WHERE type = 'Event::Festival'"
  end
end
