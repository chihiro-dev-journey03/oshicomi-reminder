class Book < ApplicationRecord
  has_many :reminders, dependent: :destroy
  has_many :recommend_list_items, dependent: :destroy

  validates :title, presence: true
end
