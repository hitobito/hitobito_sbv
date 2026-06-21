# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

require "spec_helper"

if defined?(JobObservation)
  describe Export::LabelsJob do
    let(:user) { people(:admin) }
    let(:group) { groups(:musikverband_hastdutoene) }
    let(:person) { people(:member) }
    let(:filename) { AsyncDownloadFile.create_name("people_export", user.id) }

    subject do
      Export::LabelsJob.new(
        :pdf,
        user.id,
        [person.id],
        group.id,
        filename: filename
      )
    end

    it "registers pdf address list exports under a dedicated job name" do
      subject.enqueue!
      observation = JobObservation.order(id: :desc).first

      expect(observation.job_class).to eq Sbv::Export::LabelsJob::PDF_ADDRESS_LIST_JOB_CLASS
      expect(observation.job_name).to eq "PDF-Adressliste"
    end
  end
end
