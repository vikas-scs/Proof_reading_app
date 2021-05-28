class CuponController < ApplicationController
	def index
		@coupon = Cupon.all
	end
	def show

	end
end
