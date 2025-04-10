class AddProvinceToUsers < ActiveRecord::Migration[7.2]
  def change
    add_reference :users, :province, null: true, foreign_key: true

  end
end
