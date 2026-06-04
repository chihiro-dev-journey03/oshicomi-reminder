class RecommendList < ApplicationRecord
  belongs_to :user

  has_many :recommend_list_items, dependent: :destroy
  has_many :books, through: :recommend_list_items

  accepts_nested_attributes_for :recommend_list_items, allow_destroy: true

  enum :status, { draft: 0, closed: 1, published: 2 }

  STATUS_LABELS = { draft: "下書き", closed: "非公開", published: "公開" }.freeze

  def status_label
    STATUS_LABELS[status.to_sym]
  end

  validates :title, presence: true
end
