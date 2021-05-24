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
            @admin = Admin.find(current_admin.id)
            @invites = Invite.where(reciever_id: current_admin.id)
           if params[:post_id].present?
              redirect_to reject_action_path
          end
          if params[:i_status].present?
              @invite = Invite.find(params[:invite_id].to_i)
               fine = @admin.wallet - 30
               @admin.wallet = fine
               @admin.status = "available"
               @admin.save
                @invite.post_id = params[:poste_id].to_i
               @invite.host_id = params[:host_id].to_i
               @invite.reciever_id = params[:reciever_id].to_i
                @invite.invite_status = params[:i_status]
                @invite.read_status = params[:r_status]
                @invite.error_count = params[:e_count]
                if @invite.save
                  flash[:error] = "You got fine invitation diverted successfully"
                  redirect_to index_path
               end
            end
          end
        end
      end
    end 
  end
end