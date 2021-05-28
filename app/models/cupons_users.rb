class CuponsUsers < ApplicationRecord
	belongs_to :cupons
	belongs_to :users 
end
