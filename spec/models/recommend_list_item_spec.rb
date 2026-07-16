require 'rails_helper'

RSpec.describe RecommendListItem, type: :model do
  describe "アソシエーション" do
    it { should belong_to(:recommend_list) }
    it { should belong_to(:book) }
  end

  describe "バリデーション" do
    subject { create(:recommend_list_item) }
    it { should validate_uniqueness_of(:book_id).scoped_to(:recommend_list_id) }
  end
end
