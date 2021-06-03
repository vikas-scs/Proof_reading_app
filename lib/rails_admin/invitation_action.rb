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
            @invites = Invite.all
            @posts =Post.all
           if params[:invite_id].present?
              puts "helloooooooooo"
              @invite = Invite.find(params[:invite_id].to_i)
              
              @admin = Admin.find(current_admin.id)
              
              if Invite.exists?(:host_id => @invite.host_id,:post_id => @invite.post_id, :invite_status => "accepted")
                @invite.invite_status = "reject"
                @invite.save
                puts "rihftttttttt"
                flash[:error] = "invitation accepted by another proofreader"
                redirect_to index_path
              else
                @invite.invite_status = params[:is_status]
                @invite.save
                if @invite.invite_status == "accepted"
                @admin.status = "available"
                @post = Post.find(@invite.post_id)
                @post.status = "processing"
                @post.save
                 if @admin.save
                  flash[:success] = "request accepted successfully"
                  redirect_to index_path
                 end
                end
              end
              if @invite.invite_status == "rejected"
                @invite.invite_status = "reject"
                @invite.save
                puts "hello"
                puts current_admin.id
                @adm = Admin.where(status: "available", role: "proof_reader")
                @add = @adm.ids
                if @adm.length != 0
                  for i in 0..@adm.length - 1
                    if @add[i] == current_admin.id
                      next
                    elsif Invite.exists?(:post_id => @invite.post_id, :reciever_id => @add[i])
                      next
                    else
                      puts "its comming here"
                      @invit = Invite.new
                      @invit.post_id = params[:post_id].to_i
                      @invit.host_id = params[:host_id].to_i
                      @invit.reciever_id = @add[i]
                      @invit.invite_status = "pending"
                      @invit.read_status = "pending"
                      @invit.error_count = 0
                      @invit.save
                    end
                  end
                  if @invite.save
                    flash[:success] = "invitation divirted successfully"
                    redirect_to index_path
                  end
                else
                  flash[:success] = "rejected and all proof readers are busy"
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