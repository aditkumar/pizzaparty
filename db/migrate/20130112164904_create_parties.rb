class CreateParties < ActiveRecord::Migration
  def change
    create_table :parties do |t|
      t.string :host
      t.string :location
      t.string :number

      t.timestamps
    end
  end
end
