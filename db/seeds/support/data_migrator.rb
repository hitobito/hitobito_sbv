class DataMigrator

  def initialize
    @import_date = Time.zone.now

    @vereine = Group.pluck(:name, :id).to_h
    @mitglieder_ids = {}
  end

  def parse_date(string, default: @import_date)
    date = Date.parse(string)
    date.to_s if date.year > 1900
  rescue ArgumentError, TypeError
    default
  end

  def infer_mitgliederverein(verein_name, verein_ort)
    vereins_name = [verein_name, verein_ort].join(' ')
    verband_name = verein_name

    vereins_id = [@vereine[vereins_name], @vereine[verband_name]].compact.first

    if vereins_id
      @mitglieder_ids[vereins_id] ||= load_mitglieder_verein_id(vereins_id)
    else
      nil
    end
  end

  def load_mitglieder_verein_id(vereins_id)
    Group.find(vereins_id).children.where(name: 'Mitglieder').pluck(:id).first
  end

end
