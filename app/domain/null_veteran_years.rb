# frozen_string_literal: true

#  Copyright (c) 2012-2024, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

# rubocop:disable Layout/EmptyLineBetweenDefs only one-liners, so the visual gaps do not help
class NullVeteranYears
  # mimic public readers
  def start_year = nil
  def end_year = nil
  def passive_years = []
  def years = 0

  # mimic protected readers, just to be complete
  protected def year_list = []

  # lower self-esteem of this object...
  def nil? = true      # I am kind of a nil myself...
  def <=>(other) = -1  # the other one is bigger, always
  def +(other) = other # I am nothing...
end
# rubocop:enable Layout/EmptyLineBetweenDefs
