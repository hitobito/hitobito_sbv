# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

def one_or_many
  3.times.collect { Faker::Book.author }.sample(rand(1..3)).join(' / ')
end

attrs = 25.times.collect do
  { title: Faker::Book.title,
    composed_by: one_or_many,
    arranged_by: one_or_many,
    published_by: one_or_many
  }
end

Song.seed(:title, attrs)
