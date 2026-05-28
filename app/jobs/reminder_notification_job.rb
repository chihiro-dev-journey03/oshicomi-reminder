class ReminderNotificationJob < ApplicationJob
  queue_as :reminders

  def perform(reminder_id)
    reminder = Reminder.find_by(id: reminder_id)

    unless reminder
      Rails.logger.warn("ReminderNotificationJob: reminder not found (id=#{reminder_id})")
      return
    end

    LineNotificationService.new.send_reminder(reminder)
    Rails.logger.info("ReminderNotificationJob: sent successfully (reminder_id=#{reminder_id})")
  rescue LineNotificationService::SendError => e
    Rails.logger.error("ReminderNotificationJob: LINE send failed (reminder_id=#{reminder_id}) #{e.message}")
    raise
  rescue StandardError => e
    Rails.logger.error("ReminderNotificationJob: unexpected error (reminder_id=#{reminder_id}) #{e.message}")
    raise
  end
end
