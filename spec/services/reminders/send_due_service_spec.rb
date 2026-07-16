require 'rails_helper'

RSpec.describe Reminders::SendDueService do
  let(:user) { create(:user, email: "user@example.com") }
  let(:book) { create(:book) }

  def build_daily_reminder(hour: 9, minute: 0, **opts)
    create(:reminder, user: user, book: book,
           recurrence_type: "daily", recurrence_interval: 1,
           time_hour: hour, time_minute: minute, **opts)
  end

  describe "#call" do
    context "発火ウィンドウ内に該当リマインダーがある場合" do
      it "メールを送信してsent_countを返す" do
        reminder = build_daily_reminder(hour: 9, minute: 0)
        now = Time.zone.today.in_time_zone.change(hour: 9, min: 5)

        mail_double = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
        allow(ReminderMailer).to receive(:due_reminders).and_return(mail_double)

        result = described_class.new(now: now).call

        expect(result[:sent]).to eq(1)
        expect(result[:failed]).to eq(0)
        expect(reminder.reload.status).to eq("sent")
      end
    end

    context "発火ウィンドウ外のリマインダー" do
      it "ウィンドウより前は送信しない" do
        build_daily_reminder(hour: 9, minute: 0)
        now = Time.zone.today.in_time_zone.change(hour: 8, min: 44)

        result = described_class.new(now: now).call

        expect(result[:sent]).to eq(0)
      end

      it "ウィンドウより後は送信しない" do
        build_daily_reminder(hour: 9, minute: 0)
        now = Time.zone.today.in_time_zone.change(hour: 9, min: 16)

        result = described_class.new(now: now).call

        expect(result[:sent]).to eq(0)
      end
    end

    context "当日すでに送信済みのリマインダー" do
      it "sent_atが今日の場合は再送しない" do
        reminder = build_daily_reminder(hour: 9, minute: 0, sent_at: Time.current)
        now = Time.zone.today.in_time_zone.change(hour: 9, min: 5)

        result = described_class.new(now: now).call

        expect(result[:sent]).to eq(0)
        expect(reminder.reload.status).to eq("pending")
      end
    end

    context "メール送信が失敗した場合" do
      it "failed_countを返しステータスをfailedに更新する" do
        reminder = build_daily_reminder(hour: 9, minute: 0)
        now = Time.zone.today.in_time_zone.change(hour: 9, min: 5)

        allow(ReminderMailer).to receive(:due_reminders).and_raise(StandardError, "SMTP error")

        result = described_class.new(now: now).call

        expect(result[:failed]).to eq(1)
        expect(result[:sent]).to eq(0)
        expect(reminder.reload.status).to eq("failed")
      end
    end

    context "同一ユーザーに複数リマインダーがある場合" do
      it "1通のメールにまとめて送信する" do
        book2 = create(:book)
        build_daily_reminder(hour: 9, minute: 0)
        create(:reminder, user: user, book: book2,
               recurrence_type: "daily", recurrence_interval: 1,
               time_hour: 9, time_minute: 0)
        now = Time.zone.today.in_time_zone.change(hour: 9, min: 5)

        mail_double = instance_double(ActionMailer::MessageDelivery, deliver_now: true)
        expect(ReminderMailer).to receive(:due_reminders).once.and_return(mail_double)

        result = described_class.new(now: now).call

        expect(result[:sent]).to eq(2)
      end
    end
  end
end
