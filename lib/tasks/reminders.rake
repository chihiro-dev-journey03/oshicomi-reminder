namespace :reminders do
  desc "本日分のリマインダー通知ジョブを Sidekiq にスケジュールする"
  task schedule_today: :environment do
    today = Date.current
    enqueued_count = 0

    Reminder.all.each do |reminder|
      next unless reminder.fires_today?(today)

      scheduled_at = today.in_time_zone.change(hour: reminder.time_hour, min: reminder.time_minute, sec: 0)

      if scheduled_at < Time.current
        Rails.logger.info("[reminders:schedule_today] skipped reminder_id=#{reminder.id} (scheduled_at #{scheduled_at} is in the past)")
        next
      end

      ReminderNotificationJob.set(wait_until: scheduled_at).perform_later(reminder.id)
      Rails.logger.info("[reminders:schedule_today] enqueued reminder_id=#{reminder.id} at #{scheduled_at}")
      enqueued_count += 1
    end

    Rails.logger.info("[reminders:schedule_today] done. #{enqueued_count} job(s) enqueued for #{today}")
    puts "#{enqueued_count} job(s) enqueued for #{today}"
  end
end
