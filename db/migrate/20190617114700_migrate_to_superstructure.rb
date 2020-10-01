class MigrateToSuperstructure < ActiveRecord::Migration[4.2]
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

      %w(
        Group::MitgliederverbandGeschaeftsstelle
        Group::MitgliederverbandVorstand
        Group::MitgliederverbandMusikkommission
        Group::MitgliederverbandArbeitsgruppe
        Group::MitgliederverbandKontakte
        Group::MitgliederverbandVeteranen
      ).each do |group_type|
        Group.where(parent_id: [choirs, accordeon], type: group_type)
             .update_all(type: group_type.gsub(/Mitgliederverband/, 'Root'))
      end
    end

    say_with_time 'promote choir-regionalverbaende to mitgliederverbaende' do
      choirs = 16778

      ids = Group.where(parent_id: choirs, type: 'Group::Regionalverband').pluck(:id)

      Group.where(id: ids)
           .update_all(type: 'Group::Mitgliederverband')

      %w(
        Group::RegionalverbandGeschaeftsstelle,
        Group::RegionalverbandVorstand,
        Group::RegionalverbandMusikkommission,
        Group::RegionalverbandArbeitsgruppe,
        Group::RegionalverbandKontakte,
      ).each do |group_type|
        Group.where(parent_id: ids, type: group_type)
             .update_all(type: group_type.gsub(/Regional/, 'Mitglieder'))
      end
    end

    say_with_time 'Move current roots to new admin-group' do
      Group
        .where(type: 'Group::Root', parent_id: nil)
        .update_all(parent_id: admin_layer.id, lft: nil, rgt: nil)
    end

    say_with_time 'Rebuilding nested set...' do
      Group.rebuild!(false)
    end

    unless Rails.env.test? # this breaks with the addition of paranoia to the concerts
      say_with_time 'Relink concerts to verbandsebenen' do
        Concert.find_each do |concert|
          concert.infer_verband_ids
          concert.save if concert.changes.any?
        end
      end
    end
  end

  def down
    admin_layer_ids = Group.where(type: 'Group::Generalverband').pluck(:id)
    sbv_id = 1

    say_with_time 'demote choir-mitgliederverbaende to regionalverbaende' do
      choirs = 16778

      ids = Group.where(parent_id: choirs, type: 'Group::Mitgliederverband').pluck(:id)

      Group.where(id: ids)
           .update_all(type: 'Group::Regionalverband')

      %w(
        Group::MitgliederverbandGeschaeftsstelle,
        Group::MitgliederverbandVorstand,
        Group::MitgliederverbandMusikkommission,
        Group::MitgliederverbandArbeitsgruppe,
        Group::MitgliederverbandKontakte,
      ).each do |group_type|
        Group.where(parent_id: ids, type: group_type)
             .update_all(type: group_type.gsub(/Mitglieder/, 'Regional'))
      end
    end

    say 'Please convert Group::MitgliederverbandVeteranen yourself if they exist'

    say_with_time 'demote some groups to mitgliederverband' do
      choirs = 16778
      accordeon = 218

      Group.where(id: [choirs, accordeon], type: 'Group::Root')
           .update_all(parent_id: sbv_id, type: 'Group::Mitgliederverband')

      %w(
        Group::RootGeschaeftsstelle
        Group::RootVorstand
        Group::RootMusikkommission
        Group::RootArbeitsgruppe
        Group::RootKontakte
        Group::RootVeteranen
      ).each do |group_type|
        Group.where(parent_id: [choirs, accordeon], type: group_type)
             .update_all(type: group_type.gsub(/Root/, 'Mitgliederverband'))
      end
    end

    say 'Please convert Group::RootEhrenmitglieder yourself if they exist'

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

    unless Rails.env.test? # this breaks with the addition of paranoia to the concerts
      say_with_time 'Relink concerts to verbandsebenen' do
        Concert.find_each do |concert|
          concert.infer_verband_ids
          concert.save if concert.changes.any?
        end
      end
    end
  end
end
