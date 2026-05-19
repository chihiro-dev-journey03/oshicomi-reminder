class Reminder < ApplicationRecord
  belongs_to :user
  belongs_to :book

  enum :status, { pending: 0, sent: 1, failed: 2 }

  validates :scheduled_at, presence: true
end
