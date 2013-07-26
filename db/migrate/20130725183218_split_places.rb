class SplitPlaces < ActiveRecord::Migration
  def change
    drop_table :places
    create_table :user_places do |t|
      t.string :name
      t.string :address
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.float :lat
      t.float :lon
      t.integer :user_id

      t.timestamps
    end
    create_table :trip_places do |t|
      t.string :name
      t.string :address
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip
      t.float :lat
      t.float :lon
      t.integer :trip_id

      t.timestamps
    end

  end

end
