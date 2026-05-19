class CreateReminders < ActiveRecord::Migration[7.2]
  def change
    create_table :reminders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book, null: false, foreign_key: true
      t.text :memo
      t.datetime :scheduled_at, null: false
      t.integer :status, null: false, default: 0
      t.datetime :sent_at

      t.timestamps
    end
  end
end
