class CuponController < ApplicationController
	def index
		@coupon = Cupon.all
	end
end
