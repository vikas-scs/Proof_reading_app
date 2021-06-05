class PostController < ApplicationController
	def index
       if user_signed_in?
       	@posts = current_user.posts                              #assigning posts of current user
      end
    end
  def new
    @post = Post.new                                  #creating a new post 
    @cost = Cost.find(1)                              #getting wo
  end
  def show
    @cupons = Cupon.all
    @post = Post.find(params[:id])
    if @post.status == "done"
      @post = Post.find(params[:id])
      if @post.cupon_id.present?
       @cupon = Cupon.find(@post.cupon_id)
     end
    @statement1 = Statement.where(post_id: @post.id, action: "distributing money for proofread").first
    @statement2 = Statement.where(post_id: @post.id, action: "distributing money for proofread").second
    @invite = Invite.where(post_id: @post.id).first
    @admin = Admin.find(@invite.reciever_id)
  end
  if @post.cupon_id.present?
   @cupon = Cupon.find(@post.cupon_id)
  end
    if Invite.exists?(post_id: params[:id], invite_status: "accept")                        #checking whether post is exist in invitations
         @invite = Invite.where(post_id: params[:id], invite_status: "accept").first                             #getting invitation id from post status    
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
    if params[:post] == ""
      flash[:notice] = "post can't be empty"                #dispalaying error message if fund are less
      redirect_to new_post_path
      return
    end
    @user_wallet = UserWallet.find(current_user.id)                      #getting the userwallet in at instance
    @cost = Cost.find(1)
    @post = Post.new(post_params)
    @statement = Statement.new                                     #create a statement when the locking the amount for post
    @statement.statement_type = "debit"
    @statement.action = "locking amount for post"
    @statement.user_id = current_user.id
    @statement.debit_from = current_user.email
    @statement.credit_to = current_user.email
    str = params[:post].split(" ")                                            #getting each word in a sentense for cost of word 
    if @user_wallet.balance < @cost.word_cost * str.length
      flash[:notice] = "Insufficient balance please add money"                #dispalaying error message if fund are less
      redirect_to new_wallet_path(id: current_user.id)
      return
    end
    @money = @user_wallet.balance - @cost.word_cost * str.length
    @statement.ref_id = rand(7 ** 7)  
    @post.ref_id = params[:ref_id]                              
    @post.post = params["post"]
    @post.user_id = current_user.id
    @post.status = "pending"
    if @post.save
      @statement.post_id = @post.id
      @statement.word_cost = @cost.word_cost 
      @statement.post_id = @post.id
      UserWallet.transaction do
         @user_wallet = UserWallet.lock("FOR UPDATE NOWAIT").find_by(user_id: current_user.id)
          @user_wallet.balance = @money                                               #cutting the balance from wallet after calculating word count
          @user_wallet.lock_balance = @cost.word_cost * str.length
          @user_wallet.save! 
          @statement.amount = @user_wallet.lock_balance  
          @statement.debitor_balance = @user_wallet.balance.round(2)                 #locking the balance of getting from word count
          @statement.save
      end   
      # UserMailer.with(user_id: current_user.id, post_id:@post.id).welcome_email.deliver_now
      flash[:notice] = "Post created successfully"
      redirect_to root_path
    end
  end
  def update
     @upper = params[:cupon_code].upcase                           #getting both upper and down case of input for checking that coupon is exist or not
     @down = params[:cupon_code].downcase
     @coupon = Cupon.where(coupon_name: params[:cupon_code],:coupon_name => @upper,:coupon_name => @down).first
     if @coupon.present?
        @post = Post.find(params[:id])         #getting the input cupon based on the satishfiyiing condition
        @cuponusers = CuponsUsers.where(user_id: current_user.id , cupon_id: @coupon.id)           #getting the coupon usage of the user if it usage count exceeds
        if @coupon.expired_date < Date.today                        #checking the expire date of the coupon
            flash[:alert] = "copon is already expired"
             redirect_to post_path(id: @post.id)
             return
        elsif @cuponusers.length >= @coupon.usage_count                 #checking whether the usage count of the coupon execeeds
             puts "its coming here"
             flash[:alert] = "maximum usage for coupon to user is over please try another coupon"
             redirect_to post_path(id: @post.id)
             return
        else
          @cu = CuponsUsers.new                          #adding the coupon and user details in coupon users table
          @cu.user_id = current_user.id
          @cu.cupon_id = @coupon.id
          @post.cupon_id = @coupon.id
          @cu.save
          @post.cupon_date = Date.today
          if @post.save
           flash[:notice] = "Coupon saved successfully"
          redirect_to root_path
          end
        end
      else
          flash[:notice] = "invalid coupon"                    #displaying invalid coupon if the coupon doesn't exist in coupon table
          redirect_to post_path(id: params[:id])
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
