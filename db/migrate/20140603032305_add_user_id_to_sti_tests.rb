class AddUserIdToStiTests < ActiveRecord::Migration
  def change
    change_table :sti_tests do |t|
      t.integer :user_id
    end
  end
end
