class CensusCalculator
  attr_reader :census, :group

  def initialize(census, group)
    @census = census
    @group  = group
  end

  # def count
  #   @census.song_counts.where(verein: @group)
  # end

  def total
    return unless census

    {
      verein:            vereins_total,
      mitgliederverband: verbands_total(:mitgliederverband),
      regionalverband:   verbands_total(:regionalverband)
    }
  end

  def vereins_total
    census
      .song_counts
      .where(verein: group.descendants.where(type: Group::Verein))
      .group(:verein_id).count
  end

  private

  def verbands_total(type)
    census
      .song_counts
      .where(verein: vereins_total.keys)
      .distinct
      .pluck(:verein_id, :"#{type}_id")
      .each_with_object(Hash.new([])) do |(verein, verband), memo|
      memo[verband] += [verein]
    end
  end
end
