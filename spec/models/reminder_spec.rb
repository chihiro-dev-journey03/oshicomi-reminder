require 'rails_helper'

RSpec.describe Reminder, type: :model do
  describe "アソシエーション" do
    it { should belong_to(:user) }
    it { should belong_to(:book) }
  end

  describe "バリデーション" do
    it { should validate_inclusion_of(:recurrence_type).in_array(%w[daily weekly monthly]) }
    it { should validate_presence_of(:recurrence_interval) }
    it { should validate_numericality_of(:recurrence_interval).only_integer.is_greater_than(0) }
    it { should validate_numericality_of(:time_hour).is_in(0..23) }
    it { should validate_numericality_of(:time_minute).is_in(0..59) }

    context "weeklyの場合" do
      subject { build(:reminder, :weekly) }
      it "days_of_weekが0なら無効" do
        subject.days_of_week = 0
        expect(subject).not_to be_valid
        expect(subject.errors[:days_of_week]).to be_present
      end
    end

    context "monthly（date指定）の場合" do
      subject { build(:reminder, :monthly_date) }
      it { should validate_presence_of(:day_of_month) }
      it { should validate_numericality_of(:day_of_month).is_in(1..31) }
    end

    context "monthly（weekday指定）の場合" do
      subject { build(:reminder, :monthly_weekday) }
      it { should validate_presence_of(:week_of_month) }
      it { should validate_numericality_of(:week_of_month).is_in(1..5) }
      it { should validate_presence_of(:weekday) }
      it { should validate_numericality_of(:weekday).is_in(0..6) }
    end

    context "recurrence_intervalの上限" do
      it "dailyで100日以上は無効" do
        reminder = build(:reminder, recurrence_type: "daily", recurrence_interval: 100)
        expect(reminder).not_to be_valid
      end

      it "weeklyで52週は有効" do
        reminder = build(:reminder, :weekly, recurrence_interval: 52)
        expect(reminder).to be_valid
      end

      it "monthlyで13ヶ月は無効" do
        reminder = build(:reminder, :monthly_date, recurrence_interval: 13)
        expect(reminder).not_to be_valid
      end
    end
  end

  describe "#fires_today?" do
    let(:user) { create(:user) }
    let(:book) { create(:book) }

    context "dailyリマインダー" do
      it "interval=1のとき毎日trueを返す" do
        reminder = create(:reminder, user: user, book: book,
                          recurrence_type: "daily", recurrence_interval: 1)
        expect(reminder.fires_today?(Date.today)).to be true
      end

      it "interval=3のとき作成日からちょうど3日後はtrue" do
        reminder = create(:reminder, user: user, book: book,
                          recurrence_type: "daily", recurrence_interval: 3,
                          created_at: 3.days.ago)
        expect(reminder.fires_today?(Date.today)).to be true
      end

      it "interval=3のとき作成日から1日後はfalse" do
        reminder = create(:reminder, user: user, book: book,
                          recurrence_type: "daily", recurrence_interval: 3,
                          created_at: 1.day.ago)
        expect(reminder.fires_today?(Date.today)).to be false
      end
    end

    context "weeklyリマインダー" do
      it "指定した曜日ならtrue" do
        monday = Date.today.beginning_of_week(:monday)
        reminder = create(:reminder, :weekly, user: user, book: book,
                          days_of_week: 0b0000010, recurrence_interval: 1,
                          created_at: monday - 7.days)
        expect(reminder.fires_today?(monday)).to be true
      end

      it "指定していない曜日ならfalse" do
        monday = Date.today.beginning_of_week(:monday)
        tuesday = monday + 1
        reminder = create(:reminder, :weekly, user: user, book: book,
                          days_of_week: 0b0000010, recurrence_interval: 1)
        expect(reminder.fires_today?(tuesday)).to be false
      end

      it "interval=2のとき2週後はtrue" do
        monday = Date.today.beginning_of_week(:monday)
        reminder = create(:reminder, :weekly, user: user, book: book,
                          days_of_week: 0b0000010, recurrence_interval: 2,
                          created_at: monday - 14.days)
        expect(reminder.fires_today?(monday)).to be true
      end

      it "interval=2のとき1週後はfalse" do
        monday = Date.today.beginning_of_week(:monday)
        reminder = create(:reminder, :weekly, user: user, book: book,
                          days_of_week: 0b0000010, recurrence_interval: 2,
                          created_at: monday - 7.days)
        expect(reminder.fires_today?(monday)).to be false
      end
    end

    context "monthlyリマインダー（日付指定）" do
      it "指定日当日はtrue" do
        date = Date.new(2026, 7, 15)
        reminder = create(:reminder, :monthly_date, user: user, book: book,
                          day_of_month: 15, recurrence_interval: 1,
                          created_at: date - 1.month)
        expect(reminder.fires_today?(date)).to be true
      end

      it "指定日以外はfalse" do
        date = Date.new(2026, 7, 10)
        reminder = create(:reminder, :monthly_date, user: user, book: book,
                          day_of_month: 15, recurrence_interval: 1)
        expect(reminder.fires_today?(date)).to be false
      end
    end

    context "monthlyリマインダー（曜日指定）" do
      it "第1月曜日に一致するとtrue" do
        # 2026年7月の第1月曜日 = 2026-07-06
        date = Date.new(2026, 7, 6)
        reminder = create(:reminder, :monthly_weekday, user: user, book: book,
                          week_of_month: 1, weekday: 1, recurrence_interval: 1,
                          created_at: date - 1.month)
        expect(reminder.fires_today?(date)).to be true
      end

      it "第1月曜日以外はfalse" do
        date = Date.new(2026, 7, 13) # 第2月曜日
        reminder = create(:reminder, :monthly_weekday, user: user, book: book,
                          week_of_month: 1, weekday: 1, recurrence_interval: 1)
        expect(reminder.fires_today?(date)).to be false
      end
    end
  end

  describe "#days_of_week_array=" do
    it "配列をビットマスクに変換して保存する" do
      reminder = build(:reminder)
      reminder.days_of_week_array = [ 1, 3 ] # 月・水
      expect(reminder.days_of_week).to eq(0b0001010)
    end
  end

  describe "#days_of_week_array" do
    it "ビットマスクを曜日番号の配列に変換する" do
      reminder = build(:reminder, days_of_week: 0b0001010)
      expect(reminder.days_of_week_array).to eq([ 1, 3 ])
    end
  end
end
