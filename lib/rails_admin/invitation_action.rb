module RailsAdmin
  module Config
    module Actions
      class InvitationAction < RailsAdmin::Config::Actions::Base
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
            puts current_admin.id
           @invites = Invite.where(reciever_id: current_admin.id)
           @admin = Admin.find(current_admin.id)
           puts params.inspect
           if params[:invite_id].present?
               @invite = Invite.find(params[:invite_id].to_i)
               @invite.invite_status = params[:i_status]
               if @invite.save
                 if @invite.invite_status == "accepted"
                   @admin.status = "busy"
                   @admin.save
                   flash[:success] = "request accepted successfully"
                   redirect_to index_path
                 elsif @invite.invite_status == "rejected"
                  @admin.status = "available"
                   @admin.save
                  flash[:error] = "request rejected successfully"
                  redirect_to index_path
                end
              end
            end
          end
        end
      end
    end 
  end
end