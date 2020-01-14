class MigrateToSuperstructure < ActiveRecord::Migration
  def up
    admin_layer = nil

    say_with_time 'Create new admin-group' do
      admin_layer = Group.new(
        name: 'hitobito',
        type: 'Group::Generalverband',
      )
      admin_layer.save(validate: false)
      admin_layer.reload
    end

    say_with_time 'promote some groups to root-groups' do
      choirs = 16778
      accordeon = 218

      Group.where(id: [choirs, accordeon], type: 'Group::Mitgliederverband')
           .update_all(parent_id: nil, type: 'Group::Root')
    end

    say_with_time 'Move current roots to new admin-group' do
      Group
        .where(type: 'Group::Root', parent_id: nil)
        .update_all(parent_id: admin_layer.id, lft: nil, rgt: nil)
    end

    say_with_time 'Rebuilding nested set...' do
      Group.rebuild!(false)
    end
  end

  def down
    admin_layer_ids = Group.where(type: 'Group::Generalverband').pluck(:id)

    say_with_time 'demote some groups to mitgliederverband' do
      choirs = 16778
      accordeon = 218

      Group.where(id: [choirs, accordeon], type: 'Group::Root')
           .update_all(parent_id: nil, type: 'Group::Mitgliederverband')
    end
    say_with_time 'Move current dachverband from admin-group to root' do
      Group
        .where(type: 'Group::Root', parent_id: admin_layer_ids)
        .update_all(parent_id: nil, lft: nil, rgt: nil)
    end

    say_with_time 'remove all admin-groups' do
      Group.where(id: admin_layer_ids).destroy_all
    end

    say_with_time 'Rebuilding nested set...' do
      Group.rebuild!(false)
    end
  end
end
