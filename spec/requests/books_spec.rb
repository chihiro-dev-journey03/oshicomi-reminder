require 'rails_helper'

RSpec.describe "Books", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /books/search" do
    context "キーワードが空の場合" do
      it "422を返す" do
        get search_books_path, params: { keyword: "" }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)["error"]).to be_present
      end
    end

    context "楽天APIが結果を返す場合" do
      before do
        allow(RakutenBooksService).to receive(:search).and_return([
          { title: "進撃の巨人 1", author: "諫山創", image_url: "https://example.com/img.jpg" }
        ])
      end

      it "200を返しJSON形式で結果を返す" do
        get search_books_path, params: { keyword: "進撃の巨人" }
        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body.first["title"]).to eq("進撃の巨人 1")
      end
    end

    context "未ログインの場合" do
      before { sign_out user }

      it "トップページにリダイレクトする" do
        get search_books_path, params: { keyword: "進撃の巨人" }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
