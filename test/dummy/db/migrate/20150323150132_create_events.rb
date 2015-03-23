class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :description

      t.binary  :ip_address_data, limit: 16
      t.integer :ip_address_prefix, limit: 2
      t.integer :ip_address_version, limit: 1

      t.timestamps null: false
    end
  end
end
