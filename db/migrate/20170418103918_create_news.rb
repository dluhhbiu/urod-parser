# CreateNews
class CreateNews < ActiveRecord::Migration
  def change
    create_table :news do |t|
      t.integer :urod_id
      t.string :link
      t.string :title
      t.string :text
      t.boolean :send_msg, default: false
      t.timestamps null: false
    end
  end
end
