class CreateRecommendListItems < ActiveRecord::Migration[7.2]
  def change
    create_table :recommend_list_items do |t|
      t.references :recommend_list, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.text :comment

      t.timestamps
    end
  end
end
