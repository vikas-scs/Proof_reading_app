module RailsAdmin
  module Config
    module Actions
      class InviteAction < RailsAdmin::Config::Actions::Base
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
            @invite = Invite.new
            puts params.inspect
            if Invite.exists?(post_id: params["reciever_id"].to_i)
              puts "hellooo"
              flash[:error] = "invitation already sent"
              redirect_to post_action_url
            else
              @invite.post_id = params[:post_id].to_i
              @invite.host_id = params[:host_id].to_i
              @invite.reciever_id = params[:reciever_id].to_i
              @invite.invite_status = params[:i_status]
              @invite.read_status = params[:r_status]
              @invite.error_count = params[:e_count]
              if @invite.save
                flash[:success] = "invitation sent successfully"
                redirect_to post_action_url
              end
            end           
           
          end
        end
      end
    end 
  end
end