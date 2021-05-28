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
              redirect_to reject_action_path
          end
          if params[:is_status].present?
            if @cost.fine_amount < @admin.wallet
              @invite = Invite.find(params[:invite_id].to_i)
               fine = @admin.wallet - @cost.fine_amount
               @admin.wallet = fine
               @admin.status = "available"
               @invite.invite_status = "rejected"
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
                  flash[:error] = "You got fine invitation diverted successfully"
                  redirect_to index_path
                end
              else
                flash[:error] = "You have insufficient wallet to reject, kindly start proofreading"
                redirect_to index_path
              end
            end
          end
        end
      end
    end 
  end
end