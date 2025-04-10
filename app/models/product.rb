class Product < ApplicationRecord
  belongs_to :brand
  has_and_belongs_to_many :categories
  has_one_attached :image

  scope :new_arrivals, -> { where("created_at >= ?", 3.days.ago) }
  scope :on_sale, -> { where("price < original_price") }

  # Allow searchable fields for ActiveAdmin/Ransack
  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "description", "price", "original_price", "stock", "brand_id", "created_at", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["brand", "categories", "image_attachment", "image_blob"]
  end
end

