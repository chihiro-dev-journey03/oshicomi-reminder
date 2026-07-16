require 'rails_helper'

RSpec.describe "Authentication", type: :request do
  describe "POST /users/sign_in" do
    let!(:user) { create(:user, email: "test@example.com", password: "password123") }

    context "正しい認証情報の場合" do
      it "ログインしてリマインダー一覧にリダイレクトする" do
        post user_session_path, params: {
          user: { email: "test@example.com", password: "password123" }
        }
        expect(response).to redirect_to(reminders_path)
      end
    end

    context "誤ったパスワードの場合" do
      it "ログインページにリダイレクトされる" do
        post user_session_path, params: {
          user: { email: "test@example.com", password: "wrong_password" }
        }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE /users/sign_out" do
    it "ログアウトしてトップページにリダイレクトする" do
      user = create(:user)
      sign_in user
      delete destroy_user_session_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "未ログイン時の認証保護" do
    it "リマインダー一覧へのアクセスはトップページにリダイレクト" do
      get reminders_path
      expect(response).to redirect_to(root_path)
    end
  end
end
