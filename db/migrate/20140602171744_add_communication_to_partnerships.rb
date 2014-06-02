class AddCommunicationToPartnerships < ActiveRecord::Migration
  def change
    change_table :partnerships do |t|
      t.integer :communication
    end
  end
end
