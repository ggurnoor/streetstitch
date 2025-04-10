class Order < ApplicationRecord
  belongs_to :user
  belongs_to :province
end
