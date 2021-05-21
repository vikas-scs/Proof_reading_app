class UserWalletController < ApplicationController
	def index
     @user = current_user
  end
  def new
    @wallet = User_Wallet.new 
  end
  def edit
     @wallet = User_Wallet.find(params[:id])
  end
  def show
    @wallet = User_Wallet.find(params[:id])
  end
  def create
    @wallet = User_Wallet.new(user_wallet_params)
    @wallet.user_id = current_user.id
    respond_to do |format|
      if @wallet.save
        format.html { redirect_to user_wallet_path, notice: "poast was added successfully." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user_wallet.errors, status: :unprocessable_entity }
      end
    end
  end
  def update
      @wallet = User_Wallet.find(params[:id])
      if @wallet.update(user_wallet_params)
      redirect_to new_post_path
    else
      render :edit
    end
  end
  private
    def user_wallet_params
      params.permit(:balance, :user_id)
    end
end
