class PostController < ApplicationController
	def index
       if user_signed_in?
       	@posts = current_user.posts                              #assigning posts of current user
      end
    end
  def new
    @post = Post.new 
    @cost = Cost.find(1)
  end
  def show
    @cupons = Cupon.all
    @post = Post.find(params[:id])

    if @post.status == "done"
      puts params.inspect
      @post = Post.find(params[:id])
      if @post.cupon_id.present?
       @cupon = Cupon.find(@post.cupon_id)
     end
     @state = Statement.where(post_id: @post.id, action: "distributing money for proofread")
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
    @statement = Statement.new
    @statement.statement_type = "debit"
    @statement.action = "locking amount for post"
    @statement.user_id = current_user.id
    @statement.debit_from = current_user.email
    @statement.credit_to = current_user.email
    
    puts "heloooooooo"
    str = params[:post].split(" ")                                            #getting each word in a sentense for cost of word 
    if @user_wallet.balance < @cost.word_cost * str.length
      flash[:notice] = "Insufficient balance please add money"                #dispalaying error message if fund are less
      redirect_to new_wallet_path(id: current_user.id)
      return
    end
    @money = @user_wallet.balance - @cost.word_cost * str.length
    @statement.amount = @user_wallet.lock_balance
    @statement.debitor_balance = @user_wallet.balance
    @statement.ref_id = rand(7 ** 7)  
    
    @post.ref_id = params[:ref_id]                              
    @post.post = params["post"]
    @post.user_id = current_user.id
    @post.status = "pending"
    if @post.save
      @statement.post_id = @post.id
      @statement.word_cost = @cost.word_cost 
      UserWallet.transaction do
        @user_wallet = UserWallet.first
        @user_wallet.with_lock do
          @user_wallet.balance = @money                                               #cutting the balance from wallet after calculating word count
          @user_wallet.lock_balance = @cost.word_cost * str.length                    #locking the balance of getting from word count
          @user_wallet.save! 
          @statement.save
       end
      end   
      UserMailer.with(user_id: current_user.id, post_id:@post.id).welcome_email.deliver_now
      @statement.post_id = @post.id
      flash[:notice] = "Post created successfully"
      redirect_to root_path
    end
  end
  def update
     if Cupon.exists?(:coupon_name => params[:cupon_code])
      @post = Post.find(params[:id])
      @cupon = Cupon.where(coupon_name: params[:cupon_code])
      @code = @cupon.ids
      puts @code
      @coupon = Cupon.find(@code.first)
        @cuponusers = CuponsUsers.where(user_id: current_user.id , cupon_id: @coupon.id)
        puts @cuponusers.length
        puts @coupon.usage_count
        if @coupon.expired_date < Date.today
            puts "date verified"
            flash[:alert] = "copon is already expired"
             redirect_to post_path(id: @post.id)
             return
        elsif @cuponusers.length > @coupon.usage_count
             flash[:alert] = "maximum usage for coupon to user is over please try another coupon"
             redirect_to post_path(id: @post.id)
             return
        else
          @post.cupon_id = @coupon.id
          @post.cupon_date = Date.today
          if @post.save
           flash[:notice] = "Coupon saved successfully"
          redirect_to root_path
          end
        end
      else
          flash[:notice] = "invalid coupon"
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
