class RecommendListItem < ApplicationRecord
  belongs_to :recommend_list
  belongs_to :book

  validates :book_id, uniqueness: { scope: :recommend_list_id }
end
