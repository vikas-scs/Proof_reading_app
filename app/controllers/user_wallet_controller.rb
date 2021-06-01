class UserWalletController < ApplicationController
	def index

     @user = current_user
  end
  def new
    @wallet = UserWallet.find(params[:id])
  end
  def edit
  	   puts "helooooooo"
       @wallet = UserWallet.find(params[:id])
  end
  def show
    @wallet = UserWallet.find(params[:id])
  end
  def create
  	amount = params["balance"].to_f
  	if amount < 0
  	    	flash[:notice] = "invalid amount"
  	    	redirect_to wallets_path
  	    	return
  	end
  	puts amount
  	a = current_user.user_wallet.balance
  	puts a
  	total = a + amount
    @wallet = UserWallet.find(current_user.id)
    puts total
    @wallet.balance = total
    respond_to do |format|
      if @wallet.save
        format.html { redirect_to wallets_path, notice: "money was added successfully." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user_wallet.errors, status: :unprocessable_entity }
      end
    end
  end
  def update
      @statement = Statement.new
      @post = Post.find(params[:id].to_i)
      @user = User.find(@post.user_id)
      @cost = Cost.find(1)
      puts params.inspect
      @statement.statement_type = "credit"
      @statement.action = "distributing money for proofread"
      @statement.user_id = current_user.id
      @statement.post_id = @post.id
      @statement.ref_id = rand(7 ** 7)
      puts current_user.id
      @user_wallet = UserWallet.find(current_user.id)
      @invite = Invite.find(params[:invite_id])
      @admin = Admin.find(@invite.host_id)
      @statement.admin_id = @admin.id
      @proofread = Admin.find(@invite.reciever_id)
      @total = @cost.word_cost * @invite.error_count
      puts @total
      if params[:cupon_code].present?
        if Cupon.exists?(:coupon_name => params[:cupon_code])
          @copon = Cupon.where(coupon_name: params[:cupon_code])
          puts @copon
          @coupons = @copon.ids
          @cupon = Cupon.find(@coupons.first)
          if @cupon.expired_date <= Date.today
            puts "date verified"
            flash[:alert] = "copon is already expired"
             redirect_to post_path(id: params[:post_id])
             return
          else
            @offer = (@total * @cupon.percentage) / 100
            if @offer > @cupon.amount
             @offer = @cupon.amount
            end
             puts @offer
             @post.coupon_benifit = @offer
             @post.cupon_id = @coupons.first
             @total = @total - @offer
             @percentage = (@total * @cost.admin_commission) / 100
             @pf = @total - @percentage
             @extra = @user_wallet.lock_balance - @total
             @user_wallet.lock_balance = 0  
             @cupon.usage_count = @cupon.usage_count + 1
             @cupon.save
           end
        end
      else
         @extra = @user_wallet.lock_balance - @total  
         @user_wallet.lock_balance = 0
         @percentage = (@total * @cost.admin_commission) / 100
         puts @percentage
         @pf = @total - @percentage
      end
      @post.status = "done"
      @post.save
      @admin_wallet = @admin.wallet + @percentage
      Admin.transaction do
        @admin = Admin.lock("FOR UPDATE NOWAIT").find_by(email: @admin.email)
          @admin.wallet = @admin_wallet
          @admin.save!
       end
      @admin_refund = @user_wallet.balance + @extra
      UserWallet.transaction do
       @user_wallet = UserWallet.first
       @user_wallet.with_lock do
         @user_wallet.balance = @admin_refund
         @user_wallet.save!
       end
      end
      @proof = @pf + @proofread.wallet
      Admin.transaction do
        @proofread = Admin.lock("FOR UPDATE NOWAIT").find_by(email: @proofread.email)
         @proofread.wallet = @proof
         @proofread.save!
       end
      @invite.invite_status = "done"
      @proofread.status = "available"
      @statement.debit_from = @user.email
      @statement.invite_id = @invite.id
      @statement.credit_to = @admin.email
      @statement.amount = @percentage
      @statement.debitor_balance = @user_wallet.balance
      @statement.save
      @statement = Statement.new
      @statement.statement_type = "credit"
      @statement.action = "distributing money for proofread"
      @statement.user_id = current_user.id
      @statement.post_id = @post.id
       @statement.ref_id = rand(7 ** 7)
      @statement.invite_id = @invite.id
      @statement.debit_from = @user.email
      @statement.credit_to = @proofread.email
      @statement.admin_id = @proofread.id
      @statement.amount = @pf
      @statement.debitor_balance = @user_wallet.balance
      @statement.save
      if @invite.save
        flash[:alert] = "money distributed successfully"
        redirect_to root_path
      end
  end
  private
    def user_wallet_params
      params.permit(:balance, :user_id)
    end
end
