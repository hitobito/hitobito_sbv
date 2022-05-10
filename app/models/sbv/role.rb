# frozen_string_literal: true

module Sbv::Role
  extend ActiveSupport::Concern

  Role::Types::Permissions << :song_census

end
