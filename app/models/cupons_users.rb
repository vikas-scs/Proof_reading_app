class CuponsUsers < ApplicationRecord
	belongs_to :cupon
	belongs_to :user 
end
