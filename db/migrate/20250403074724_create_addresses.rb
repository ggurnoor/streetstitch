class CreateAddresses < ActiveRecord::Migration[7.2]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :street
      t.string :city
      t.string :postal_code
      t.references :province, null: false, foreign_key: true

      t.timestamps
    end
  end
end
