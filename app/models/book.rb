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

  # author または image_url が欠けている場合、楽天APIで1巻の情報を補完する
  def enrich_from_rakuten!
    return if author.present? && image_url.present?

    # 「タイトル 1」で検索して1巻を狙い打ちにする。ヒットしなければタイトルのみで再検索
    results = RakutenBooksService.search("#{title} 1")
    results = RakutenBooksService.search(title) if results.empty?
    return if results.empty?

    # タイトルが最も短いものを1巻として採用
    chosen = results.min_by { |r| r[:title].length }

    update!(
      author: author.presence || chosen[:author],
      image_url: image_url.presence || chosen[:image_url]
    )
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
