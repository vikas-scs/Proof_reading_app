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
      @post = Post.find(params[:id])
      @user = User.find(@post.user_id)
      @cost = Cost.find(1)
      @user_wallet = UserWallet.find(current_user.id)
      @invite = Invite.find(params[:invite_id])
      @admin = Admin.find(@invite.host_id)
      @proofread = Admin.find(@invite.reciever_id)
      @total = @cost.word_cost * @invite.error_count
      @cutoff = @user_wallet.lock_balance - @total
      @user_wallet.lock_balance = @cutoff
      @percentage = @total % @cost.admin_commission
      @admin_wallet = @admin.wallet + @percentage
      @admin.wallet = @admin_wallet
      @pf = @total - @percentage
      @proof = @pf + @proofread.wallet
      @proofread.wallet = @proof
      @post.status = "done"
      @post.save
      @user_wallet.save
      @admin.save
      if @proofread.save
        flash[:alert] = "money distributed successfully"
        redirect_to root_path
      end
  end
  private
    def user_wallet_params
      params.permit(:balance, :user_id)
    end
end
