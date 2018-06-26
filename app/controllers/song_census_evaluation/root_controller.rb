module SongCensusEvaluation
  class RootController < BaseController
    def show
      super
      @total = CensusCalculator.new(@census, @group).total
    end
  end
end
