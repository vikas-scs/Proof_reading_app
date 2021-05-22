class PostController < ApplicationController
	def index
       if user_signed_in?
       	@posts = current_user.posts
       	   if current_user.sign_in_count == 1
               @user = current_user
              puts params.inspect
               @wallet = UserWallet.new(user_wallet_params)
              @wallet.user_id = current_user.id
              @wallet.balance = 0
              @wallet.save
    	      puts "successfully"
            end
        end
    end
  def new
    @post = Post.new 
  end
  def show
    @post = Post.find(params[:id])
  end
  def edit
     @post = Post.find(params[:id])
  end
  def create
    @post = Post.new(post_params)
    puts "heloooooooo"
    @post.post = params["post"]
    @post.user_id = current_user.id
    @post.status = "pending"
    @post.save
    flash[:notice] = "                    post created successfully"
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
