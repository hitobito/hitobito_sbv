module Sbv::Role

  Role::Types::Permissions << :song_census

  class SuisaAdmin < ::Role
    self.permissions = [:group_read, :song_census]
  end

end
