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
end
