module RailsAdmin
  module Config
    module Actions
      class RejectAction < RailsAdmin::Config::Actions::Base
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
        register_instance_option :http_methods do
          [:get]
        end
        register_instance_option :controller do
          Proc.new do
           @invite = Invite.find(params[:invite_id].to_i)
           @invite.invite_status = params[:i_status]
           if @invite.save
              if @invite.invite_status == "accept"
                 flash[:success] = "request accepted successfully"
                 redirect_to rails_admin_path
                  elsif @invite.invite_status == "reject"
                flash[:error] = "request rejected successfully"
                redirect_to rails_admin_path
              end
            end
          end
        end
      end
    end 
  end
end