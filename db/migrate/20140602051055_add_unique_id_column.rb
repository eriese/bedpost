class AddUniqueIdColumn < ActiveRecord::Migration
  def change
    change_table :profiles do |t|
      t.string :uid
    end
  end
end
