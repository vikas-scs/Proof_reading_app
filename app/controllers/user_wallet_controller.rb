class UserWalletController < ApplicationController
	def index

     @user = current_user
  end
  def new
    @wallet = UserWallet.find(params[:id])
  end
  def edit
       @wallet = UserWallet.find(params[:id])
  end
  def show
    @wallet = UserWallet.find(params[:id])
  end
  def create
    @statement = Statement.new                              #creating statement when the user adding money to the wallet
    @statement.statement_type = "credit"
    @statement.action = "adding money to user wallet"
    @statement.user_id = current_user.id
    @statement.credit_to = current_user.email
    @statement.ref_id = rand(7 ** 7)
  	amount = params["balance"].to_f
  	if amount < 0                                             #the adding money should be greater then 0 
  	    	flash[:notice] = "invalid amount"
  	    	redirect_to wallets_path
  	    	return
  	end
  	puts amount
    @statement.amount = amount
  	a = current_user.user_wallet.balance
  	puts a
  	total = a + amount
    @wallet = UserWallet.find(current_user.id)
    puts total
    @wallet.balance = total           
     UserWallet.transaction do                                    #locking the transaction for avoiding deadlocks
       @user_wallet = UserWallet.first
       @user_wallet.with_lock do
         @wallet.balance = total
         @wallet.save
         @statement.debitor_balance = @wallet.balance
         @statement.save
       end
      end
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
      @statement = Statement.new                          #creating a new statement for distributing money after proofreading
      @post = Post.find(params[:id].to_i)
      @user = User.find(@post.user_id)
      @state = Statement.where(action: "locking amount for post", post_id: @post.id).first
      word_cost = @state.word_cost
      @costs = Cost.find(1)
      @statement.statement_type = "credit"
      @statement.action = "distributing money for proofread"
      @statement.user_id = current_user.id
      @statement.post_id = @post.id
      @statement.ref_id = rand(7 ** 7)
      @user_wallet = UserWallet.find(current_user.id)
      @invite = Invite.find(params[:invite_id])
      @admin = Admin.find(@invite.host_id)
      @statement.admin_id = @admin.id
      @total = word_cost * @invite.error_count
      if params[:cupon_code].present?                              #checking whether the coupon is applied or not
        @upper = params[:cupon_code].upcase                           #getting both upper and down case of input for checking that coupon is exist or not
        @down = params[:cupon_code].downcase
         @cupon = Cupon.where('lower(coupon_name) = ?', params[:cupon_code].downcase).first
         if @cupon.present?
            @post = Post.find(params[:id])   #checking whther the coupon exist or not 
          @cuponusers = CuponsUsers.where(user_id: current_user.id , cupon_id: @cupon.id)
          if @post.cupon_date.present?                             #checking whether the coupon was pre-saved after creating the post 
            if @post.cupon_date <=  Date.today
              if @cupon.percentage.present? && @cupon.amount.present?     #checking whether amount and percentage are available in table
                @offer = (@total * @cupon.percentage) / 100
                if @offer > @cupon.amount
                  @offer = @cupon.amount
                end
                @post.coupon_benifit = @offer
                @post.cupon_id = @cupon.id
                @total = @total - @offer
                @percentage = (@total * @costs.admin_commission) / 100
                @pf = @total - @percentage
                @extra = @user_wallet.lock_balance - @total
                @cupon.save
              elsif !@cupon.amount.present?              #if the amount is not present in coupon table
                @offer = (@total * @cupon.percentage) / 100
                @post.coupon_benifit = @offer
                @post.cupon_id = @cupon.id
                @total = @total - @offer
                @percentage = (@total * @costs.admin_commission) / 100
                @pf = @total - @percentage
                @extra = @user_wallet.lock_balance - @total
                @cupon.save
              elsif !@cupon.percentage.present?                   #if the percentage is not available in coupon table
                if @cupon.amount > @total
                   @offer = @total
                   @total = 0
                   @cu = CuponsUsers.new
                   @cu.user_id = current_user.id
                   @cu.cupon_id = @cupon.id
                   @post.coupon_benifit = @offer
                   @post.cupon_id = @cupon.id
                   @percentage = 0
                   @pf = 0
                   @extra = @user_wallet.lock_balance
                   @cupon.save
                   @cu.save
                else
                   @offer = @total - @cupon.amount
                   @post.coupon_benifit = @offer
                   @post.cupon_id = @cupon.first
                   @total = @total - @offer
                   @percentage = (@total * @costs.admin_commission) / 100
                   @pf = @total - @percentage
                   @extra = @user_wallet.lock_balance - @total
                   @cupon.save
                end
              end    
            elsif @cupon.expired_date < Date.today            #if coupon applied that after proof read, checking its expiry date
              flash[:alert] = "copon is already expired"
              redirect_to post_path(id: params[:post_id])
              return
            end
          elsif @cupon.expired_date < Date.today       #if coupon applied that after proof read, checking its expiry date   
            flash[:alert] = "copon is already expired"
            redirect_to post_path(id: params[:post_id])
            return
          elsif @cuponusers.length >= @cupon.usage_count      #checking that usage count for user to use coupon for a post
            flash[:alert] = "maximum usage for coupon to user is over please try another coupon"
            redirect_to post_path(id: params[:post_id])
            return
          else          #if the coupon applied at accept the proofread is completed
            
              if @cupon.percentage.present? && @cupon.amount.present?                      #checking whether amount and percentage are available in table
                @offer = (@total * @cupon.percentage) / 100
                if @offer > @cupon.amount
                  @offer = @cupon.amount
                end
                @cu = CuponsUsers.new
                @cu.user_id = current_user.id
                @cu.cupon_id = @cupon.id
                @post.coupon_benifit = @offer
                @post.cupon_id = @cupon.id
                @total = @total - @offer
                @percentage = (@total * @costs.admin_commission) / 100
                @pf = @total - @percentage
                @extra = @user_wallet.lock_balance - @total
                @cupon.save
                @cu.save
              elsif !@cupon.amount.present?                              #if the amount is not present in coupon table
                @offer = (@total * @cupon.percentage) / 100
                @cu = CuponsUsers.new
                @cu.user_id = current_user.id
                @cu.cupon_id = @cupon.id
                @post.coupon_benifit = @offer
                @post.cupon_id = @cupon.id
                @total = @total - @offer
                @percentage = (@total * @costs.admin_commission) / 100
                @pf = @total - @percentage
                @extra = @user_wallet.lock_balance - @total
                @cupon.save
                @cu.save
              elsif !@cupon.percentage.present?                           #if the percentage is not available in coupon table
                if @cupon.amount > @total
                   @offer = @total
                   @total = 0
                   @cu = CuponsUsers.new
                   @cu.user_id = current_user.id
                   @cu.cupon_id = @cupon.id
                   @post.coupon_benifit = @offer
                   @post.cupon_id = @cupon.first
                   @percentage = 0
                   @pf = 0
                   @extra = @user_wallet.lock_balance
                   @cupon.save
                   @cu.save
                else
                   @offer = @total - @cupon.amount
                   @cu = CuponsUsers.new
                   @cu.user_id = current_user.id
                   @cu.cupon_id = @cupon.id
                   @post.coupon_benifit = @offer
                   @post.cupon_id = @cupon.first
                   @total = @total - @offer
                   @percentage = (@total * @costs.admin_commission) / 100
                   @pf = @total - @percentage
                   @extra = @user_wallet.lock_balance - @total
                   @cupon.save
                   @cu.save
                end
              end    
            end
        elsif !Cupon.exists?(:coupon_name => params[:cupon_code])           #if the entered coupon is invalid
           flash[:alert] = "invalid coupon"
            redirect_to post_path(id: params[:post_id])
            return
        end
      else                                                          #accpting the proofread without applying coupon
         @extra = @user_wallet.lock_balance - @total  
         @user_wallet.lock_balance = 0
         @percentage = (@total * @costs.admin_commission) / 100
         @pf = @total - @percentage
         @post.coupon_benifit = 0
      end
      @proofread = Admin.find(@invite.reciever_id)
      @admin_wallet = @admin.wallet + @percentage
      @statement.debit_from = @user.email
      @statement.invite_id = @invite.id
      @statement.credit_to = @admin.email
      @statement.amount = @percentage
      @proof = @pf + @proofread.wallet 
       Admin.transaction do
        @admin = Admin.lock("FOR UPDATE NOWAIT").find_by(email: @admin.email)
          @admin.wallet = @admin_wallet
          @admin.save!
          @statement.debitor_balance = @admin.wallet.round(2)
          @statement.save  
       end
      @admin_refund = @user_wallet.balance + @extra
      @invite.invite_status = "done"
      @proofread.status = "available"
      @statement1 = Statement.new                              #creating a new statement for distributing money after proofreading    
      @statement1.statement_type = "credit"
      @statement1.action = "distributing money for proofread"
      @statement1.user_id = current_user.id
      @statement1.post_id = @post.id
      @statement1.ref_id = rand(7 ** 7)
      @statement1.invite_id = @invite.id
      @statement1.debit_from = @user.email
      @statement1.credit_to = @proofread.email
      @statement1.admin_id = @proofread.id
      @statement1.amount = @pf
      Admin.transaction do
        @proofread = Admin.lock("FOR UPDATE NOWAIT").find_by(email: @proofread.email)
         @proofread.wallet = @proof
         @proofread.save!
         @statement1.debitor_balance = @proofread.wallet.round(2)
         @statement1.save
       end
       @statement2 = Statement.new                 #creating a statemet for refunding money to admin
       @statement2.statement_type = "credit"
      @statement2.action = "refund_amount"
      @statement2.user_id = current_user.id
      @statement2.post_id = @post.id
       @statement2.ref_id = rand(7 ** 7)
      @statement2.invite_id = @invite.id
      @statement2.credit_to = @user.email
      @statement2.admin_id = @admin.id
      @statement2.amount = @extra
      
       UserWallet.transaction do
        @user_wallet = UserWallet.lock("FOR UPDATE NOWAIT").find_by(user_id: current_user.id)
         @user_wallet.balance = @admin_refund 
         @user_wallet.save!
         @statement2.debitor_balance = @user_wallet.balance.round(2)
         @statement2.save
         end
         @post.status = "done"
      @post.save
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
