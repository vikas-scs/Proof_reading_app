module RailsAdmin
  module Config
    module Actions
      class ReadAction < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)
        register_instance_option :visible? do
           true
        end
        register_instance_option :collection do
          true
        end
        register_instance_option :link_icon do
          #FontAwesome Icons
          'icon-share'
        end
        register_instance_option :pjax? do
          false
        end
        register_instance_option :http_methods do
          [:get]
        end
        register_instance_option :controller do
          Proc.new do
            @posts = Post.all
            @cost = Cost.find(1)
            @invites = Invite.all
           if params[:post_id].present?
              UserMailer.with(post_id: params[:post_id]).accept_email.deliver_now
              puts params.inspect
              redirect_to accept_action_path
          end
          if params[:is_status].present?
            @invite = Invite.find(params[:invite_id])
            @post = Post.find(@invite.post_id)
            @user = User.find(@post.user_id)
            @user_wallet = UserWallet.find(@user.user_wallet.id)
            puts @user_wallet.lock_balance
            puts @cost.fine_amount
            @fine = (@user_wallet.lock_balance * @cost.fine_amount) / 100
            puts @fine
            @admin = Admin.find(@invite.reciever_id)
            if @fine < @admin.wallet
              puts @admin.wallet
              @statement = Statement.new
              @statement.debit_from = @admin.email
              @statement.statement_type = "credit"
              @statement.action = "fined by rejecting invitation"
               @statement.ref_id = "rej#{rand(9 ** 9)}"
               @super = Admin.find(@invite.host_id)
               

               @statement.post_id = @post.id
               @statement.user_id = @user.id
               @statement.admin_id = @admin.id
               
               puts @statement.debit_from 
               @statement.credit_to = @super.email
               puts "super_admin_email#{@super.email}"
               @super_add = @super.wallet + @fine
               @statement.amount = @fine
               
               Admin.transaction do
                @admin = Admin.lock("FOR UPDATE NOWAIT").find_by(email: @admin.email)
                  @wall = @admin.wallet - @fine
                  @admin.wallet = @wall
                  @admin.save!
                  @statement.debitor_balance = @admin.wallet
                  @statement.save
                end
               @statement1 = Statement.new
               @statement1.debit_from = @admin.email
               @statement1.statement_type = "debit"
               @statement1.action = "getting fine from rejecting invitation"
               @statement1.ref_id = "fine#{rand(9 ** 9)}"
               @statement1.post_id = @post.id
               @statement1.user_id = @user.id
                @statement1.admin_id = @super.id 
               @statement1.amount = @fine
               @statement1.credit_to = @super.email
               
               Admin.transaction do 
                  @super = Admin.lock("FOR UPDATE NOWAIT").find_by(email: @super.email)
                  @super.wallet = @super_add
                  @super.save!
                  @statement1.debitor_balance = @super.wallet
                   @statement1.save
                  end
                  UserMailer.with(admin_id: @admin.id, post_id: @post, fine: @fine).fine_email.deliver_now
               @post.status = "pending"
               @post.save
               @admin.status = "available"
               @invite.invite_status = "reject"
               puts "comiiiiiiiiiiiiii"
               @admin.save 
                @adm = Admin.where(status: "available", role: "proof_reader")
                puts "trrsssssssss"
                @add = @adm.ids
                if @adm.length != 0
                    for i in 0..@adm.length - 1
                      if @add[i] == current_admin.id
                         next
                      elsif Invite.exists?(:post_id => @invite.post_id, :reciever_id => @add[i], :invite_status => "pending")
                        next
                      elsif Invite.exists?(:post_id => @invite.post_id, :reciever_id => @add[i], :invite_status => "reject")
                        next
                      elsif Invite.exists?(:post_id => @invite.post_id, :reciever_id => @add[i], :invite_status => "corrected")
                        next
                      else
                        @invit = Invite.new
                        @invit.post_id = @invite.post_id
                        @invit.host_id = @invite.host_id
                        @invit.reciever_id = @add[i]
                         @invit.invite_status = "pending"
                        @invit.read_status = "pending"
                        @invit.error_count = 0
                       @invit.save
                  end
                 end
                end
                if @invite.save
                  flash[:success] = "You got fine invitation diverted successfully"
                  redirect_to index_path
                end
              else
                flash[:error] = "You have insufficient wallet to reject, kindly recharge wallet"
                redirect_to index_path
              end
            end
          end
        end
      end
    end 
  end
end