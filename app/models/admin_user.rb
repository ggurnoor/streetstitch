class AdminUser < ApplicationRecord
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable

  # Required for ActiveAdmin filters/search
  def self.ransackable_attributes(auth_object = nil)
    %w[id email created_at updated_at current_sign_in_at sign_in_count]
  end
end
#added relationships