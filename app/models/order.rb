class Order < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :province
  has_many :order_items, dependent: :destroy

  # Updated enum values: 'pending' replaces 'new'
  enum status: { pending: 0, paid: 1, shipped: 2 }

  validates :address, presence: true
  validates :subtotal, :gst, :pst, :hst, :total,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  # Optional method to format address
  def formatted_address
    address.to_s
  end

  # ActiveAdmin: define searchable associations
  def self.ransackable_associations(auth_object = nil)
    %w[user province order_items]
  end

  # ActiveAdmin: define searchable attributes
  def self.ransackable_attributes(auth_object = nil)
    %w[
      id user_id province_id address
      subtotal gst pst hst total
      created_at updated_at status
      stripe_payment_id stripe_session_id
    ]
  end
end
