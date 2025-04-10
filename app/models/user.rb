class User < ApplicationRecord
  has_one :cart, dependent: :destroy
  has_one :address, dependent: :destroy
  belongs_to :province, optional: true
  has_many :orders, dependent: :destroy

  after_create :create_cart

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ROLES = %w[admin customer]

  def admin?
    role == 'admin'
  end

  def customer?
    role == 'customer'
  end

  private

  def create_cart
    Cart.create(user: self)
  end
end
