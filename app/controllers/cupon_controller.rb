class CuponController < ApplicationController
	def index
		@coupon = Cupon.all
	end
	def show
     @post = Post.find(params[:id].to_i)
      @user = User.find(@post.user_id)
      @cost = Cost.find(1)
      puts current_user.id
      @user_wallet = UserWallet.find(current_user.id)
      @invite = Invite.find(params[:invite_id])
      @admin = Admin.find(@invite.host_id)
      @proofread = Admin.find(@invite.reciever_id)
      @total = @cost.word_cost * @invite.error_count
      if params[:cupon_code].present?
        if Cupon.exists?(:coupon_name => params[:cupon_code])
          @copon = Cupon.where(:coupon_name => params[:cupon_code])
          @coupons = @coupon.ids
          @cupon = Cupon.find(@coupon[0])
           @offer = (@total * @cost.percentage) / 100
           @post.cupon_id = @coupon[0]
           @cutoff = @user_wallet.lock_balance - @offer
           @user_wallet.lock_balance = 0
           @percentage = (@offer * @cost.admin_commission) / 100
           @pf = @offer - @percentage
           @cupon.usage_count += 1
           @cupon.save
        end
      else
         @cutoff = @user_wallet.lock_balance - @total
         @user_wallet.lock_balance = 0
         @percentage = (@total * @cost.admin_commission) / 100
         puts @percentage
         @pf = @total - @percentage
      end
      @admin_wallet = @admin.wallet + @percentage
      @admin.wallet = @admin_wallet
      @admin_refund = @admin_wallet.balance + @cutoff
      @admin_wallet.balance = @admin_refund
      @proof = @pf + @proofread.wallet
      @proofread.wallet = @proof
      @post.status = "done"
      @post.save
      @user_wallet.save
      @admin.save
      if @proofread.save
        @invite.destroy
        flash[:alert] = "money distributed successfully"
        redirect_to root_path
      end
	end
end
