# frozen_string_literal: true

#  Copyright (c) 2018-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Person::ActiveYears
  extend ActiveSupport::Concern

  included do
    Person::PUBLIC_ATTRS << :active_years
    Person::FILTER_ATTRS << :active_years << [:prognostic_active_years, :integer]
  end

  def prognostic_active_years
    update_active_years if active_years.nil?

    if active_role?
      active_years.succ
    else
      active_years
    end
  end

  def update_active_years
    cache_active_years
    save(validate: false)
  end

  def cache_active_years
    self.active_role = active_member_role?
    self.active_years = calculate_active_years
  end

  private

  def veteran_role_condition
    {
      type: [
        Group::VereinMitglieder::Mitglied,
        Role::MitgliederMitglied
      ].map(&:sti_name)
    }
  end

  def active_member_role?
    roles.where(veteran_role_condition).any?
  end

  def calculate_active_years(end_date = Time.zone.now)
    roles.with_inactive.where(veteran_role_condition).map do |role|
      VeteranYears.new((role.start_on || role.created_at).year, (role.end_on || end_date).year)
    end.sort.sum.years.to_i
  end
end
