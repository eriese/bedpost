class AddDefaultMin < ActiveRecord::Migration
  def up
    change_column(:profiles, :min_window, :integer, :default => 6)
  end

  def down
    change_column(:profiles, :min_window, :integer, :default => nil)
  end
end
