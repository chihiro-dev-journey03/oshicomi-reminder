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

  # 楽天APIから1巻の著者・書影を取得して補完する（書影は既存があっても1巻に揃える）
  def enrich_from_rakuten!
    chosen = RakutenBooksService.find_volume_one(title)
    return unless chosen

    attrs = {}
    attrs[:author] = chosen[:author] if author.blank? && chosen[:author].present?
    attrs[:image_url] = chosen[:image_url] if chosen[:image_url].present?
    update!(attrs) if attrs.any?
  rescue StandardError => e
    Rails.logger.error("Book#enrich_from_rakuten! failed for '#{title}': #{e.message}")
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

    # 見つからなければ新規作成し、すぐにRakutenで補完する
    book = create!(title: title)
    book.enrich_from_rakuten!
    book
  end
end
