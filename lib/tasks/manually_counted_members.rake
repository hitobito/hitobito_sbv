# frozen_string_literal: true

#  Copyright (c) 2021, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

namespace :manually_counted_members do
  desc 'Set manually_counted_members of given group id to true, ' \
       'including all subgroups. Only concerning vereine'
  task :activate, [:group_id] => :environment do |_t, args|
    group = Group.find(args[:group_id])

    return puts "Group with id #{args[:group_id]} was not found" unless group

    group.self_and_descendants.where(type: Group::Verein.sti_name).each do |subgroup|
      subgroup.update!({ manually_counted_members: true, reported_members: 0 })

      puts "Activated manually_counted_members for group id #{subgroup.id}"
    end
  end

  desc 'Set manually_counted_members of given group id to false, ' \
       'including all subgroups. Only concerning vereine'
  task :deactivate, [:group_id] => :environment do |_t, args|
    group = Group.find(args[:group_id])

    return puts "Group with id #{args[:group_id]} was not found" unless group

    group.update!(manually_counted_members: false)

    puts "Deactivated manually_counted_members for group id #{group.id}"
  end
end
