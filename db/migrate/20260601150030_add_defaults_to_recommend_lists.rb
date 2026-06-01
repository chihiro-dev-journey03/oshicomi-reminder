class AddDefaultsToRecommendLists < ActiveRecord::Migration[7.2]
  def change
    change_column_null :recommend_lists, :title, false
    change_column_default :recommend_lists, :status, from: nil, to: 0
    change_column_null :recommend_lists, :status, false
  end
end
