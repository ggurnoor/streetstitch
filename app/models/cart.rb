class Cart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy

  # Optional, but you can validate association existence if needed
end
