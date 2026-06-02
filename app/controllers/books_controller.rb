class BooksController < ApplicationController
  before_action :authenticate_user!

  def search
    keyword = params[:keyword].to_s.strip

    if keyword.blank?
      return render json: { error: "キーワードを入力してください" }, status: :unprocessable_entity
    end

    # 候補表示用。DBには保存せず楽天APIの結果をそのまま返す（登録はリマインダー保存時）
    books = RakutenBooksService.search(keyword)

    render json: books
  end
end
