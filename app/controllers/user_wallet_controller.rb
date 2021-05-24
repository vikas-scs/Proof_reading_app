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
      @invite = Invite.find(params[:invite_id].to_i)
      @invite.status = params[:i_status]
      if @invite.save
        if @invite.status == "accept"
          flash[:success] = "request accepted successfully"
          redirect_to rails_admin_path
        elsif @invite.status == "reject"
          flash[:error] = "request rejected successfully"
          redirect_to rails_admin_path
        end
      end
  end
  private
    def user_wallet_params
      params.permit(:balance, :user_id)
    end
end
