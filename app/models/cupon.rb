class Cupon < ApplicationRecord
	has_and_belongs_to_many :users
	validates :coupon_name, :uniqueness => true
end
