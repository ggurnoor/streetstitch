class Category < ApplicationRecord
  has_and_belongs_to_many :products

  # 👇 Add this method to fix ActiveAdmin filtering/searching
  def self.ransackable_associations(auth_object = nil)
    ["products"]
  end

  # (Optional) If you also want to allow attribute-based search
  def self.ransackable_attributes(auth_object = nil)
    ["id", "name", "created_at", "updated_at"]
  end
end
