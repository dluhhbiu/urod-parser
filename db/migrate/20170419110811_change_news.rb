# ChangeNews
class ChangeNews < ActiveRecord::Migration
  def change
    change_table :news do |t|
      t.string :format
    end
  end
end
