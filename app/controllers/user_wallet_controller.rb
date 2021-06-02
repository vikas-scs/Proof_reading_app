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
          @cuponusers = CuponsUsers.where(user_id: current_user.id , cupon_id: @cupon.id)
          puts "coooooooo"
          puts @cuponusers.length
          puts @cupon.usage_count
          if @post.cupon_date.present?
            if @post.cupon_date <=  Date.today
              @offer = (@total * @cupon.percentage) / 100
              if @offer > @cupon.amount
                @offer = @cupon.amount
              end
              @cu = CuponsUsers.new
              @cu.user_id = current_user.id
              @cu.cupon_id = @cupon.id
              @post.coupon_benifit = @offer
              @post.cupon_id = @coupons.first
              @total = @total - @offer
              @percentage = (@total * @cost.admin_commission) / 100
              @pf = @total - @percentage
              @extra = @user_wallet.lock_balance - @total
              @cupon.save
              @cu.save
            elsif @cupon.expired_date < Date.today
              puts "date verified"
              flash[:alert] = "copon is already expired"
              redirect_to post_path(id: params[:post_id])
              return
            end
          elsif @cupon.expired_date < Date.today
            puts "date verified"
            flash[:alert] = "copon is already expired"
            redirect_to post_path(id: params[:post_id])
            return
          elsif @cuponusers.length > @cupon.usage_count
            puts "over usage"
            flash[:alert] = "maximum usage for coupon to user is over please try another coupon"
            redirect_to post_path(id: params[:post_id])
            return
          else
            @offer = (@total * @cupon.percentage) / 100
            if @offer > @cupon.amount
              @offer = @cupon.amount
            end
            @cu = CuponsUsers.new
            puts @offer
            @cu.user_id = current_user.id
            @cu.cupon_id = @cupon.id
            @post.coupon_benifit = @offer
            @post.cupon_id = @coupons.first
            @total = @total - @offer
            @percentage = (@total * @cost.admin_commission) / 100
            @pf = @total - @percentage
            puts @percentage
            puts "getting here"
            @extra = @user_wallet.lock_balance - @total
            @cupon.save
            @cu.save
          end
        elsif !Cupon.exists?(:coupon_name => params[:cupon_code])
           puts "coming here"
           flash[:alert] = "invalid coupon"
            redirect_to post_path(id: params[:post_id])
            return
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
      
      @admin_refund = @user_wallet.balance + @extra
      UserWallet.transaction do
       @user_wallet = UserWallet.first
       @user_wallet.with_lock do
         @user_wallet.balance = @admin_refund
         @user_wallet.save!
       end
      end
      @proof = @pf + @proofread.wallet
      
      @invite.invite_status = "done"
      @proofread.status = "available"
      @statement.debit_from = @user.email
      @statement.invite_id = @invite.id
      @statement.credit_to = @admin.email
      @statement.amount = @percentage
      
      Admin.transaction do
        @proofread = Admin.lock("FOR UPDATE NOWAIT").find_by(email: @proofread.email)
         @proofread.wallet = @proof
         @proofread.save!
         @statement.debitor_balance = @proofread.wallet
         @statement.save
       end
      @statement1 = Statement.new
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
        @admin = Admin.lock("FOR UPDATE NOWAIT").find_by(email: @admin.email)
          @admin.wallet = @admin_wallet
          @admin.save!
          @statement1.debitor_balance = @admin.wallet
          @statement1.save
          
       end  
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
