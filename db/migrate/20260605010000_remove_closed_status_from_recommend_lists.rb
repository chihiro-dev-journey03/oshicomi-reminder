class RemoveClosedStatusFromRecommendLists < ActiveRecord::Migration[7.2]
  def up
    # closed(1) → draft(0) に変換
    execute "UPDATE recommend_lists SET status = 0 WHERE status = 1"
    # published(2) → published(1) に変換
    execute "UPDATE recommend_lists SET status = 1 WHERE status = 2"
  end

  def down
    # published(1) → published(2) に戻す
    execute "UPDATE recommend_lists SET status = 2 WHERE status = 1"
  end
end
