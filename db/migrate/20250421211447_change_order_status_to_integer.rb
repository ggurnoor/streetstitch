class ChangeOrderStatusToInteger < ActiveRecord::Migration[7.0]
  def change
    # First, add a temporary new column for integer status
    add_column :orders, :status_temp, :integer, default: 0

    # Then, migrate existing string statuses into integers manually
    Order.reset_column_information

    Order.find_each do |order|
      case order.status
      when 'new'
        order.update_column(:status_temp, 0)
      when 'paid'
        order.update_column(:status_temp, 1)
      when 'shipped'
        order.update_column(:status_temp, 2)
      end
    end

    # Then, remove the old status column
    remove_column :orders, :status

    # Rename the new status_temp column to status
    rename_column :orders, :status_temp, :status
  end
end
