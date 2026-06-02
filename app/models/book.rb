class Book < ApplicationRecord
  has_many :reminders, dependent: :destroy
  has_many :recommend_list_items, dependent: :destroy
  has_many :recommend_lists, through: :recommend_list_items

  validates :title, presence: true

  # author または image_url が欠けている場合、楽天APIから1巻の情報を補完する
  def enrich_from_rakuten!
    return if author.present? && image_url.present?

    chosen = RakutenBooksService.find_volume_one(title)
    return unless chosen

    attrs = {}
    attrs[:author] = chosen[:author] if author.blank? && chosen[:author].present?
    attrs[:image_url] = chosen[:image_url] if image_url.blank? && chosen[:image_url].present?
    update!(attrs) if attrs.any?
  rescue StandardError => e
    Rails.logger.error("Book#enrich_from_rakuten! failed for '#{title}': #{e.message}")
  end

  # ベースタイトルで1件だけ登録し、楽天APIから1巻の著者・書影を補完する
  def self.find_or_create_by_base_title(title)
    normalized_title = title.to_s.strip
    book = find_by(title: normalized_title) || create!(title: normalized_title)
    book.enrich_from_rakuten!
    book.reload
  end
end
