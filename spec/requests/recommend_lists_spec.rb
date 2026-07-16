require 'rails_helper'

RSpec.describe "RecommendLists", type: :request do
  let(:user)  { create(:user) }
  let(:owner) { create(:user) }

  describe "GET /recommend_lists" do
    let!(:published_list) { create(:recommend_list, :published, user: owner) }
    let!(:draft_list)     { create(:recommend_list, user: owner) }

    it "ログインなしでも公開リストを表示できる" do
      get recommend_lists_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /recommend_lists/:id" do
    context "公開リストの場合" do
      let!(:list) { create(:recommend_list, :published, user: owner) }

      it "ログインなしでも表示できる" do
        get recommend_list_path(list)
        expect(response).to have_http_status(:ok)
      end
    end

    context "下書きリストを他人が見る場合" do
      let!(:list) { create(:recommend_list, user: owner) }

      it "トップページにリダイレクトする" do
        sign_in user
        get recommend_list_path(list)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "GET /recommend_lists/my_lists" do
    before { sign_in user }

    it "200を返す" do
      get my_lists_recommend_lists_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /recommend_lists" do
    before { sign_in user }

    context "正常系" do
      it "リストを作成してリダイレクトする" do
        expect {
          post recommend_lists_path, params: {
            recommend_list: { title: "おすすめ漫画リスト", status: :draft }
          }
        }.to change(RecommendList, :count).by(1)
        expect(response).to redirect_to(recommend_list_path(RecommendList.last))
      end
    end

    context "タイトルが空の場合" do
      it "422を返す" do
        post recommend_lists_path, params: {
          recommend_list: { title: "" }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /recommend_lists/:id" do
    let!(:list) { create(:recommend_list, user: user, title: "古いタイトル") }

    before { sign_in user }

    context "正常系" do
      it "タイトルを更新してリダイレクトする" do
        patch recommend_list_path(list), params: {
          recommend_list: { title: "新しいタイトル", status: :draft }
        }
        expect(response).to redirect_to(recommend_list_path(list))
        expect(list.reload.title).to eq("新しいタイトル")
      end
    end

    context "他人のリストを編集しようとする場合" do
      let!(:other_list) { create(:recommend_list, user: owner) }

      it "root_pathにリダイレクトする" do
        patch recommend_list_path(other_list), params: {
          recommend_list: { title: "乗っ取り" }
        }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE /recommend_lists/:id" do
    let!(:list) { create(:recommend_list, user: user) }

    before { sign_in user }

    it "リストを削除してリダイレクトする" do
      expect {
        delete recommend_list_path(list)
      }.to change(RecommendList, :count).by(-1)
      expect(response).to redirect_to(my_lists_recommend_lists_path)
    end
  end
end
