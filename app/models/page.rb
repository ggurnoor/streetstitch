class Page < ApplicationRecord
  validates :title, :slug, :content, presence: true
end
