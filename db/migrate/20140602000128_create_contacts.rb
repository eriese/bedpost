class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :user_inst
      t.string :partner_inst
      t.integer :encounter_id
      t.boolean :barriers
      t.timestamps
    end
  end
end
