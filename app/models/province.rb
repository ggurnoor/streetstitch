class Province < ApplicationRecord
  has_many :users

  validates :name, presence: true
  validates :pst, :gst, :hst,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }
end
