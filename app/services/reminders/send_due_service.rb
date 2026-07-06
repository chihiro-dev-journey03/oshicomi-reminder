module Reminders
  class SendDueService
    WINDOW = 15.minutes

    def initialize(now: Time.current)
      @now = now
    end

    def call
      due_reminders = Reminder.includes(:user, :book).select { |r| due?(r) }
      grouped = due_reminders.group_by(&:user_id)

      sent_count = 0
      failed_count = 0

      grouped.each_value do |reminders|
        user = reminders.first.user
        if send_email(user, reminders)
          sent_count += reminders.size
        else
          failed_count += reminders.size
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

    def send_email(user, reminders)
      ReminderMailer.due_reminders(user, reminders).deliver_now
      reminders.each { |r| r.update!(status: :sent, sent_at: Time.current) }
      Rails.logger.info("[Reminders::SendDueService] sent email user_id=#{user.id} count=#{reminders.size}")
      true
    rescue StandardError => e
      reminders.each { |r| r.update!(status: :failed) }
      Rails.logger.error("[Reminders::SendDueService] email send failed user_id=#{user.id} #{e.message}")
      false
    end
  end
end

