if Delayed::Job.table_exists? && !Rails.env.test?
  # schedule cron jobs here
   Rails.application.config.to_prepare do
     RefreshActiveYearsJob.new.schedule
  end
end
