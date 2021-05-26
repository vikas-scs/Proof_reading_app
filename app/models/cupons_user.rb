class CuponsUser < ApplicationRecord
	belongs_to :cupons
	belongs_to :users
end
