class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  # ✅ Allowlist searchable attributes for ActiveAdmin / Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[
      id order_id product_id quantity price
      created_at updated_at
    ]
  end

  # ✅ Allowlist searchable associations if needed in future
  def self.ransackable_associations(auth_object = nil)
    %w[order product]
  end
end
