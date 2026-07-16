require 'rails_helper'

RSpec.describe "Users::Profiles", type: :request do
  let(:user) { create(:user, name: "テストユーザー", email: "test@example.com") }

  before { sign_in user }

  describe "GET /profile" do
    it "200を返す" do
      get profile_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /profile/edit" do
    it "200を返す" do
      get edit_profile_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /profile" do
    context "正常系" do
      it "プロフィールを更新してリダイレクトする" do
        patch profile_path, params: {
          user: { name: "新しい名前", email: "new@example.com" }
        }
        expect(response).to redirect_to(profile_path)
        expect(user.reload.name).to eq("新しい名前")
      end
    end

    context "不正なメールアドレスの場合" do
      it "422を返す" do
        patch profile_path, params: {
          user: { name: "名前", email: "invalid-email" }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "未ログインの場合" do
      before { sign_out user }

      it "トップページにリダイレクトする" do
        patch profile_path, params: { user: { name: "hacker" } }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
