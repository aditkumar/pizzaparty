class AddDateToParty < ActiveRecord::Migration
  def change
    add_column :parties, :time, :datetime
  end
end
