# frozen_string_literal: true

#  Copyright (c) 2020-2024, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Export::Tabular::GroupParticipations
  class List < Export::Tabular::Base
    self.model_class = Event::GroupParticipation
    self.row_class = Export::Tabular::GroupParticipations::Row

    def attributes # rubocop:disable Metrics/MethodLength
      [
        :group_id,
        :secondary_group_id,
        :music_style,
        :parade_music,
        :music_type,
        :music_level,

        :group_dirigent,
        :group_contact,
        :group_email,
        :group_address,
        :group_zip_code,
        :group_town,
        :group_country,
        :group_recognized_members
      ]
    end

    def data_rows(format = nil)
      return enum_for(:data_rows) unless block_given?

      list.each do |entry|
        yield values(entry, format)
        if entry.joint_participation? && entry.secondary_group.present?
          yield values(secondary_group(entry), format)
        end
      end
    end

    private

    def human_attribute(attr)
      return super unless attr.to_s.starts_with?("group_")
      return super if attr == :group_id

      Group.human_attribute_name(attr.to_s.delete_prefix("group_"))
    end

    def secondary_group(leader)
      partner = leader.dup
      partner.id = nil

      switch(leader, partner, :group_id, :secondary_group_id)

      partner
    end

    def switch(first, second, attr_first, attr_second)
      second.write_attribute(attr_first, first.read_attribute(attr_second))
      second.write_attribute(attr_second, first.read_attribute(attr_first))

      true
    end
  end
end
