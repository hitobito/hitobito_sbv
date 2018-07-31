class VeteranYears
  def initialize(start_year, end_year)
    @start_year = start_year
    @end_year   = end_year
  end

  def years
    @end_year - @start_year
  end
end
