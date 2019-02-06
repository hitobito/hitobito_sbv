namespace :reactivate do
  task deleted: [:environment] do
    restore_list = Wagons.find('sbv').root.join('db/seeds/production/deleted.csv')
    raise unless restore_list.exist?

    MigrationDate  = Date.new(2019, 1, 30)
    DeploymentDate = Date.new(2019, 2, 2)

    CSV.parse(restore_list.read, headers: true).each do |group|
      named_group = Group.deleted.find_by(name: group['verein'])

      groups = if named_group.present?
                 [named_group]
               else
                 Group.deleted.where(['name LIKE ?', group['nomSociete'] + '%']).to_a
               end

      groups.each do |deleted_group|
        puts "Restoring #{deleted_group.name}"
        Reactivator.restore_group(deleted_group)
        Reactivator.restore_roles(deleted_group)
        Reactivator.restore_subgroups(deleted_group)
      end
    end
  end
end

module Reactivator
  module_function

  def restore_group(deleted_group)
    deleted_group.update(
      swoffice_id: nil, # prevent deletion with next seeding
      deleted_at: nil   # restore deleted group
    )
  end

  def restore_subgroups(deleted_group)
    %w(Vorstand Mitglieder Kontakte Musikkommission).each do |group_name|
      sub_group = deleted_group.children.with_deleted.where(name: group_name).first
      next if sub_group.nil?

      puts "          -> #{sub_group.name}"
      sub_group.restore!
      restore_roles(sub_group)
    end
  end

  def restore_roles(group)
    group.roles.with_deleted.where(
      deleted_at: (MigrationDate.prev_day..DeploymentDate.next_day)
    ).each do |role|
      role.restore!
    end
  end
end
