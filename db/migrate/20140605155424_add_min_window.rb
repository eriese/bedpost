class AddMinWindow < ActiveRecord::Migration
  def change
    change_table :profiles do |t|
      t.integer :min_window
    end
  end
end
