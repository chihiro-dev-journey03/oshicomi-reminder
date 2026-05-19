class CreateBooks < ActiveRecord::Migration[7.2]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.string :author
      t.string :image_url

      t.timestamps
    end
  end
end
