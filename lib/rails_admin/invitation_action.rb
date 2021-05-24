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
           @admins = Admin.all
           puts params.inspect
           puts "helloooooooooo"
           if params[:invite_id].present?
              puts "helloooooooooo"
              @invite = Invite.find(params[:invite_id].to_i)
              @invite.invite_status = params[:is_status]
              if @invite.save
                puts "helloooooo"
                if @invite.invite_status == "accepted"
                  @admin.status = "busy"
                  @admin.save
                  flash[:success] = "request accepted successfully"
                  redirect_to index_path
                elsif @invite.invite_status == "rejected"
                  puts "hello"
                  @invite.post_id = params[:post_id].to_i
                  @invite.host_id = params[:host_id].to_i
                  @invite.reciever_id = params[:reciever_id].to_i
                  @invite.invite_status = params[:i_status]
                  @invite.read_status = params[:r_status]
                  @invite.error_count = params[:e_count]
                  if @invite.save
                    flash[:success] = "invitation diverted successfully"
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
end