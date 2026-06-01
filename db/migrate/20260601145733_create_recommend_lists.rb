class CreateRecommendLists < ActiveRecord::Migration[7.2]
  def change
    create_table :recommend_lists do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :status, null: false, default: 0

      t.timestamps
    end
  end
end
