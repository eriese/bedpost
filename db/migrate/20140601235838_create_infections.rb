class CreateInfections < ActiveRecord::Migration
  def change
    create_table :infections do |t|
      t.string :disease
      t.boolean :positive
      t.integer :sti_test_id

      t.timestamps
    end
  end
end
