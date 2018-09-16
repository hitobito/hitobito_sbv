if Delayed::Job.table_exists? && !Rails.env.test?
  # schedule cron jobs here
  RefreshActiveYearsJob.new.schedule
end
