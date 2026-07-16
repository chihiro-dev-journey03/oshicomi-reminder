require 'rails_helper'

RSpec.describe Book, type: :model do
  describe "バリデーション" do
    it { should validate_presence_of(:title) }
  end

  describe "アソシエーション" do
    it { should have_many(:reminders).dependent(:destroy) }
    it { should have_many(:recommend_list_items).dependent(:destroy) }
    it { should have_many(:recommend_lists).through(:recommend_list_items) }
  end

  describe "#large_image_url" do
    it "image_urlがなければnilを返す" do
      book = build(:book, image_url: nil)
      expect(book.large_image_url).to be_nil
    end

    it "_ex=パラメータを200x200に置換する" do
      book = build(:book, image_url: "https://example.com/cover_ex=64x64.jpg")
      expect(book.large_image_url).to eq("https://example.com/cover_ex=200x200.jpg")
    end
  end
end
