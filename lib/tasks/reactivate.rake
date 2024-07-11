# frozen_string_literal: true

namespace :reactivate do
  task deleted: [:environment] do
    restore_list = Wagons.find("sbv").root.join("db/seeds/production/deleted.csv")
    raise unless restore_list.exist?

    reactivator = Reactivator.new(
      Date.new(2019, 1, 30), # migration date
      Date.new(2019, 2, 2)   # deployment date
    )

    CSV.parse(restore_list.read, headers: true).each do |group|
      named_group = Group.deleted.find_by(name: group["verein"])

      groups = if named_group.present?
        [named_group]
      else
        Group.deleted.where(
          ["name LIKE ? AND town = ?", group["nomSociete"] + "%", group["nomLocalite"]]
        ).to_a
      end

      groups.each do |deleted_group|
        reactivator.restore(deleted_group)
      end
    end
  end
end

class Reactivator
  def initialize(start_date, end_date)
    @start_date = start_date
    @end_date = end_date
  end

  def restore(deleted_group)
    puts "Restoring #{deleted_group.name}"
    restore_group(deleted_group)
    restore_roles(deleted_group)
    restore_subgroups(deleted_group)
  end

  def restore_group(deleted_group)
    swoffice_id = if deleted_group.swoffice_id == -1
      nil # prevent deletion with next seeding, -1 is a magic value
    else
      deleted_group.swoffice_id
    end
    deleted_group.update(
      swoffice_id: swoffice_id,
      deleted_at: nil # restore deleted group
    )
  end

  def restore_subgroups(deleted_group)
    %w[Vorstand Mitglieder Kontakte Musikkommission].each do |group_name|
      sub_group = deleted_group.children.with_deleted.where(name: group_name).first
      next if sub_group.nil?

      puts "          -> #{sub_group.name}"
      sub_group.restore!
      restore_roles(sub_group)
    end
  end

  def restore_roles(group)
    group.roles.with_deleted.where(
      deleted_at: (@start_date.prev_day..@end_date.next_day)
    ).find_each do |role|
      role.restore!
    end
  end
end
