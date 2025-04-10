class Page < ApplicationRecord
  # Add this method to allow ActiveAdmin search/filter functionality
  def self.ransackable_attributes(auth_object = nil)
    ["id", "title", "slug", "content", "created_at", "updated_at"]
  end
end
