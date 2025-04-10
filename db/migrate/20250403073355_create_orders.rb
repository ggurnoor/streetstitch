class CreateOrders < ActiveRecord::Migration[7.2]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :subtotal
      t.decimal :gst
      t.decimal :pst
      t.decimal :hst
      t.decimal :total
      t.string :address
      t.references :province, null: false, foreign_key: true

      t.timestamps
    end
  end
end
