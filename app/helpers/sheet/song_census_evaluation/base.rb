module Sheet::SongCensusEvaluation
  class Base < Sheet::Base
    self.parent_sheet = Sheet::Group

    def title
      SongCensus.model_name.human
    end

  end
end
