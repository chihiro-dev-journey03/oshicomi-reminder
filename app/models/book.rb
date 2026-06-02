class Book < ApplicationRecord
  has_many :reminders, dependent: :destroy
  has_many :recommend_list_items, dependent: :destroy
  has_many :recommend_lists, through: :recommend_list_items

  validates :title, presence: true

  def self.find_or_create_from_rakuten(book_data)
    find_or_create_by(title: book_data[:title]) do |book|
      book.author = book_data[:author]
      book.image_url = book_data[:image_url]
    end
  end

  # タイトル入力（巻数なし）でも、楽天API経由で登録済みの巻数付きレコードを優先して返す
  def self.find_or_create_by_base_title(title)
    # 完全一致
    book = find_by(title: title)
    return book if book

    # 巻数付きレコードを探す（タイトルが「入力値 」で始まるもの、巻数が小さい順）
    book = where("title LIKE ?", "#{sanitize_sql_like(title)} %")
             .order(Arel.sql("LENGTH(title) ASC"))
             .first
    return book if book

    # 見つからなければ新規作成
    create!(title: title)
  end
end
