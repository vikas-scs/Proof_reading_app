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

    if @post.status == "done"
       @cupon = Cupon.find(@post.cupon_id)
  
       @state = Statement.where(post_id: @post.id)
       @statement = @state.ids
    puts @statement
    @statement1 = Statement.find(@statement.first)
    puts @statement1.amount
    @statement2 = Statement.find(@statement.second)
    puts @statement2.amount
    @invites = Invite.where(post_id: @post.id)
    @invit = @invites.ids
    @invite = Invite.find(@invit.first)
    @admin = Admin.find(@invite.reciever_id)
    puts @post.post
  end
  if @post.cupon_id.present?
   @cupon = Cupon.find(@post.cupon_id)
  end
    if Invite.exists?(post_id: params[:id], invite_status: "accept")                        #checking whether post is exist in invitations
      @invi = Invite.where(post_id: params[:id], invite_status: "accept")
      @idd = @invi.ids
         @invite = Invite.find(@idd.first)                             #getting invitation id from post status
        puts @invite.invite_status    
      end
     respond_to do |format|
      format.html
      format.pdf do
        render template: "project/edit.html.erb",            #rendering pdf file through view
        layout: 'pdf.html.erb',
        pdf: "#{@project.name}",
        disposition: 'attachment'                            #providing  downloading option
        return
      end
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
    UserWallet.transaction do
        @user_wallet = UserWallet.first
        @user_wallet.with_lock do
          @user_wallet.balance = @money                                               #cutting the balance from wallet after calculating word count
          @user_wallet.lock_balance = @cost.word_cost * str.length                    #locking the balance of getting from word count
          @user_wallet.save! 
       end
      end         
    @post.ref_id = params[:ref_id]                              
    @post.post = params["post"]
    @post.user_id = current_user.id
    @post.status = "pending"
    @post.save
    flash[:notice] = "Post created successfully"
    redirect_to root_path
  end
  def update
      @post = Post.find(params[:id])
      @cupon = Cupon.where(coupon_name: params[:cupon_code])
      @code = @cupon.ids
      puts @code
      @coupon = Cupon.find(@code.first)
      @post.cupon_id = @coupon.id
      if @post.save
        flash[:notice] = "Coupon saved successfully"
        redirect_to root_path
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
