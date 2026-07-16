require 'rails_helper'

RSpec.describe RecommendList, type: :model do
  describe "バリデーション" do
    it { should validate_presence_of(:title) }
  end

  describe "アソシエーション" do
    it { should belong_to(:user) }
    it { should have_many(:recommend_list_items).dependent(:destroy) }
    it { should have_many(:books).through(:recommend_list_items) }
  end

  describe "enum :status" do
    it { should define_enum_for(:status).with_values(draft: 0, published: 1) }
  end

  describe "#display_status_label" do
    it "draftのとき '下書き' を返す" do
      list = build(:recommend_list, status: :draft)
      expect(list.display_status_label).to eq("下書き")
    end

    it "publishedのとき '公開中' を返す" do
      list = build(:recommend_list, status: :published)
      expect(list.display_status_label).to eq("公開中")
    end
  end
end
