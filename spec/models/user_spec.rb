require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーション" do
    it { should validate_uniqueness_of(:email).case_insensitive.with_message("はすでに使用されています") }

    context "メールアドレスが入力されている場合" do
      it "正しい形式なら有効" do
        user = build(:user, email: "test@example.com")
        expect(user).to be_valid
      end

      it "不正な形式なら無効" do
        user = build(:user, email: "invalid-email")
        expect(user).not_to be_valid
      end
    end

    context "メールアドレスが空の場合" do
      it "空白を許可する" do
        user = build(:user, email: "")
        expect(user.errors[:email]).to be_empty
      end
    end
  end

  describe "アソシエーション" do
    it { should have_many(:reminders).dependent(:destroy) }
    it { should have_many(:recommend_lists).dependent(:destroy) }
  end

  describe "#email_registered?" do
    it "メールアドレスが登録済みならtrueを返す" do
      user = build(:user, email: "user@example.com")
      expect(user.email_registered?).to be true
    end

    it "LINEダミーメールならfalseを返す" do
      user = build(:line_user)
      expect(user.email_registered?).to be false
    end

    it "メールアドレスが空ならfalseを返す" do
      user = build(:user, email: "")
      expect(user.email_registered?).to be false
    end
  end
end
