class RecommendList < ApplicationRecord
  belongs_to :user

  has_many :recommend_list_items, dependent: :destroy
  has_many :books, through: :recommend_list_items

  accepts_nested_attributes_for :recommend_list_items

  enum :status, { draft: 0, private: 1, public: 2 }

  validates :title, presence: true
end
