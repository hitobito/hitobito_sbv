class VeteranYears

  attr_reader :start_year, :end_year

  def initialize(start_year, end_year)
    @start_year = start_year
    @end_year   = end_year
  end

  def years
    @end_year - @start_year
  end

  def <=>(other)
    @start_year <=> other.start_year
  end

  def +(other)
    new_start   = [@start_year, other.start_year].min
    new_end     = [@end_year, other.end_year].max

    self.class.new(new_start, new_end)
  end

end
