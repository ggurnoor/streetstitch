class Product < ApplicationRecord
  belongs_to :brand
  has_and_belongs_to_many :categories
  has_one_attached :image

  validates :name, :description, :price, :original_price, :stock, presence: true
  validates :price, :original_price, :stock,
            numericality: { greater_than_or_equal_to: 0 }
end
