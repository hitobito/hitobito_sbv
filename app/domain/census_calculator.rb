# frozen_string_literal: true

#  Copyright (c) 2012-2020, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

class CensusCalculator
  attr_reader :census, :group

  def initialize(census, group)
    @census = census
    @group  = group
  end

  def total
    return unless census

    {
      verein: vereins_total,
      mitgliederverband: verbands_total(:mitgliederverband),
      regionalverband: verbands_total(:regionalverband)
    }
  end

  def vereins_total
    census
      .concerts
      .where(concerts: { verein_id: group.descendants.where(type: Group::Verein) })
      .distinct
      .pluck(:verein_id, :reason)
      .each_with_object({}) do |(verein, reason), memo|
        next if memo[verein].present? # any reason

        memo[verein] = reason || 'played'
      end
  end

  private

  def verbands_total(type)
    census
      .concerts
      .where(concerts: { verein_id: vereins_total.keys })
      .distinct
      .pluck(:verein_id, :"#{type}_id")
      .each_with_object(Hash.new([])) do |(verein, verband), memo|
        memo[verband] += [verein]
      end
  end
end
