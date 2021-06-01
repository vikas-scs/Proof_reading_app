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
            @admins = Admin.all
            @posts = Post.all
            @cost = Cost.find(1)
            @admin = Admin.find(current_admin.id)
            @invites = Invite.all
           if params[:post_id].present?
              puts params.inspect
              redirect_to accept_action_path
          end
          if params[:is_status].present?
            @invite = Invite.find(params[:invite_id].to_i)
            @post = Post.find(@invite.post_id)
            @user = User.find(@post.user_id)
            @user_wallet = UserWallet.find(@user.user_wallet.id)
            puts @user_wallet.lock_balance
            puts @cost.fine_amount
            @fine = (@user_wallet.lock_balance * @cost.fine_amount) / 100
            if @fine < @admin.wallet
              @statement = Statement.new
              @statement.statement_type = "debit"
              @statement.action = "fined by rejecting invitation"
               @statement.ref_id = "rej#{rand(9 ** 9)}"
               @super = Admin.find(@invite.host_id)
               @wall = @admin.wallet - @fine
               Admin.transaction do
                  @admin = Admin.first
                  @admin.with_lock do
                  @admin.wallet = @wall
                  @admin.save!
                  end
               end
               @statement.post_id = @post.id
               @statement.user_id = @user.id
               @statement.admin_id = @admin.id
               @statement.debit_from = @admin.email
               @statement.credit_to = @super.email
               @super_add = @super.wallet + @fine
               @statement.amount = @fine
               @statement.debitor_balance = @admin.wallet
               @statement.save
               @statement = Statement.new
               @statement.statement_type = "credit"
               @statement.action = "getting fine from rejecting invitation"
               @statement.ref_id = "fine#{rand(9 ** 9)}"
               @statement.post_id = @post.id
               @statement.user_id = @user.id
                @statement.admin_id = @super.id
               Admin.transaction do
                  @super = Admin.first
                  @super.with_lock do
                  @super.wallet = @super_add
                  @super.save!
                  end
               end 
               @statement.debit_from = @admin.email
               @statement.amount = @fine
               @statement.credit_to = @super.email
               @statement.debitor_balance = @admin.wallet
               @statement.save
               @admin.status = "available"
               @invite.invite_status = "reject"
               puts "comiiiiiiiiiiiiii"
               @admin.save 
                @adm = Admin.where(status: "available", role: "proof_reader")
                puts "trrsssssssss"
                @add = @adm.ids
                if !@adm.length == 0
                    for i in 0..@adm.length - 1
                      if @add[i] != current_admin.id
                        @invit = Invite.new
                        @invit.post_id = params[:poste_id].to_i
                        @invit.host_id = params[:host_id].to_i
                        @invit.reciever_id = @add[i]
                         @invit.invite_status = params[:i_status]
                        @invit.read_status = params[:r_status]
                        @invit.error_count = params[:e_count]
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