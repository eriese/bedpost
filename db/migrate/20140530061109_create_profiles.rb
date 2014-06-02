class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.string :email
      t.string :name
      t.string :password_digest
      t.string :pronoun
      t.string :anus_name
      t.string :genital_name

      t.timestamps
    end
  end
end
