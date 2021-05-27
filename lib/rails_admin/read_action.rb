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
            @cost = Cost.find(1)
            @admin = Admin.find(current_admin.id)
            @invites = Invite.where(reciever_id: current_admin.id)
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
               @admin.save 
                @admins.each do |admin| 
                  if admin.role == "proof_reader"
                      if admin.id != current_admin.id
                    @invit = Invite.new
                    @invit.post_id = params[:poste_id].to_i
                    @invit.host_id = params[:host_id].to_i
                    @invit.reciever_id = admin.id
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