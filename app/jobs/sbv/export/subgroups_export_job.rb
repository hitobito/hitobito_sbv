module Sbv::Export::SubgroupsExportJob

  def initialize(user_id, group, options)
    super(user_id, group, options)
    @exporter = Export::Tabular::Groups::AddressList
  end

  private

  def entries
    super.where(type: types.collect(&:sti_name) )
  end

  def types
    [
      Group::Mitgliederverband,
      Group::Regionalverband,
      Group::Verein,
    ]
  end

end
