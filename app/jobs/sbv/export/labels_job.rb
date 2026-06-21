# frozen_string_literal: true

#  Copyright (c) 2026, Schweizer Blasmusikverband. This file is part of
#  hitobito_sbv and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_sbv.

module Sbv::Export::LabelsJob
  PDF_ADDRESS_LIST_JOB_CLASS = "Export::PdfAddressListJob"

  def enqueue!(options = {})
    delayed_job = super
    rename_job_observation_for_pdf_address_list!
    delayed_job
  end

  private

  def pdf_address_list_export?
    @format == :pdf && @options[:label_format_id].blank?
  end

  def rename_job_observation_for_pdf_address_list!
    return unless pdf_address_list_export?
    return unless defined?(@job_observation_id) && @job_observation_id

    job_observation.update!(job_class: PDF_ADDRESS_LIST_JOB_CLASS)
  end
end
