module Reminders
  class SendDueService
    WINDOW = 15.minutes

    def initialize(now: Time.current)
      @now = now
    end

    def call
      sent_count = 0
      failed_count = 0

      Reminder.includes(:user, :book).find_each do |reminder|
        next unless due?(reminder)

        if send_reminder(reminder)
          sent_count += 1
        else
          failed_count += 1
        end
      end

      Rails.logger.info("[Reminders::SendDueService] done. sent=#{sent_count} failed=#{failed_count}")
      { sent: sent_count, failed: failed_count }
    end

    private

    attr_reader :now

    def due?(reminder)
      return false unless reminder.fires_today?
      return false if sent_today?(reminder)

      scheduled_at = Date.current.in_time_zone.change(
        hour: reminder.time_hour,
        min: reminder.time_minute,
        sec: 0
      )

      scheduled_at <= now && scheduled_at > now - WINDOW
    end

    def sent_today?(reminder)
      reminder.sent_at&.to_date == Date.current
    end

    def send_reminder(reminder)
      LineNotificationService.new.send_reminder(reminder)
      reminder.update!(status: :sent, sent_at: Time.current)
      Rails.logger.info("[Reminders::SendDueService] sent reminder_id=#{reminder.id}")
      true
    rescue LineNotificationService::SendError => e
      reminder.update!(status: :failed)
      Rails.logger.error("[Reminders::SendDueService] LINE send failed reminder_id=#{reminder.id} #{e.message}")
      false
    rescue StandardError => e
      reminder.update!(status: :failed)
      Rails.logger.error("[Reminders::SendDueService] unexpected error reminder_id=#{reminder.id} #{e.message}")
      false
    end
  end
end
