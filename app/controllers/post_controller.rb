class PostController < ApplicationController
	def index
       if user_signed_in?
       	@posts = current_user.posts                              #assigning posts of current user
        end
    end
  def new
    @post = Post.new 
  end
  def show
    @cupons = Cupon.all
    @post = Post.find(params[:id])
    puts @post.post
    if Invite.exists?(post_id: params[:id], invite_status: "accept") 
         puts "hellooooooooo"                        #checking whether post is exist in invitations
      @invi = Invite.where(post_id: params[:id], invite_status: "accept")
      @idd = @invi.ids
         @invite = Invite.find(@idd[0])                             #getting invitation id from post status
      puts @invite.id
       if @invite.error_count >= 0
         @post.post = @invite.read_status
         @post.status = "corrected"                                #assigning status  for  post if proofreading is done  
         @post.save
      end
    else

    end
  end
  def edit
     @post = Post.find(params[:id])
  end
  def create
    @user_wallet = UserWallet.find(current_user.id)
    @cost = Cost.find(1)
    @post = Post.new(post_params)
    puts "heloooooooo"
    str = params[:post].split(" ")                                            #getting each word in a sentense for cost of word 
    if @user_wallet.balance < @cost.word_cost * str.length
      flash[:notice] = "Insufficient balance please add money"                #dispalaying error message if fund are less
      redirect_to new_wallet_path(id: current_user.id)
      return
    end
    @money = @user_wallet.balance - @cost.word_cost * str.length        
    @user_wallet.balance = @money                                               #cutting the balance from wallet after calculating word count
    @user_wallet.lock_balance = @cost.word_cost * str.length                    #locking the balance of getting from word count
    @user_wallet.save                               
    @post.post = params["post"]
    @post.user_id = current_user.id
    @post.status = "pending"
    @post.save
    flash[:notice] = "Post created successfully"
    redirect_to root_path
  end
  def update
      @post = Post.find(params[:id])

      if @post.update(post_params)
      redirect_to post_path
    else
      render :edit
    end
  end
  def destroy
  	 @post = Post.find(params[:id])
    @post.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: "post was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  private
    def post_params
      params.permit(:post, :status, :user_id)
    end
    def user_wallet_params
      params.permit(:balance, :user_id)
    end
end
