class CreatePartnerships < ActiveRecord::Migration
  def change
    create_table :partnerships do |t|
      t.integer :user_id
      t.integer :partner_id
      t.integer :familiarity
      t.integer :exclusivity

      t.timestamps
    end
  end
end
