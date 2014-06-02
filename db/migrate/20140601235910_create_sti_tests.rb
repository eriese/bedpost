class CreateStiTests < ActiveRecord::Migration
  def change
    create_table :sti_tests do |t|
      t.date :date_taken

      t.timestamps
    end
  end
end
