class CreateEncounters < ActiveRecord::Migration
  def change
    create_table :encounters do |t|
      t.boolean :fluid
      t.text :notes
      t.integer :self_risk
      t.date :took_place
      t.integer :user_id
      t.integer :partner_id

      t.timestamps
    end
  end
end
