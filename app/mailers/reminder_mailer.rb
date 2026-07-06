class ReminderMailer < ApplicationMailer
  def due_reminders(user, reminders)
    @user = user
    @reminders = reminders
    mail(to: user.email, subject: "【推しコミリマインダー】リマインダー通知")
  end
end
