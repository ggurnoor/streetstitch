class Order < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :province
  has_many :order_items, dependent: :destroy

  validates :address, presence: true
  validates :subtotal, :gst, :pst, :hst, :total,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  # Helper to format the address cleanly (optional)
  def formatted_address
    address.to_s
  end

  def self.ransackable_associations(auth_object = nil)
    %w[user province order_items]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[
      id user_id province_id address
      subtotal gst pst hst total
      created_at updated_at
    ]
  end
end
