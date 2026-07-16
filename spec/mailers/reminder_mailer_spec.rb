require 'rails_helper'

RSpec.describe ReminderMailer, type: :mailer do
  describe "#due_reminders" do
    let(:user)     { create(:user, email: "user@example.com", name: "テストユーザー") }
    let(:book)     { create(:book, title: "進撃の巨人") }
    let(:reminder) { create(:reminder, user: user, book: book) }
    let(:mail)     { described_class.due_reminders(user, [reminder]) }

    it "宛先が正しい" do
      expect(mail.to).to eq(["user@example.com"])
    end

    it "件名が正しい" do
      expect(mail.subject).to eq("【推しコミリマインダー】リマインダー通知")
    end

    it "本文にマンガタイトルが含まれる" do
      decoded = mail.text_part ? mail.text_part.decoded : mail.body.decoded
      expect(decoded).to include("進撃の巨人")
    end
  end
end
