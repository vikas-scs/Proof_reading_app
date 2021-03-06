module RailsAdmin
  module Config
    module Actions
      class PostAction < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)
        register_instance_option :visible? do
           true
        end
        register_instance_option :member do
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
            if params[:id].present?
            @id = params[:id]
            @post = Post.find(@id)
            if @post.status == "pending" 
              @arr = Array.new
              @arr.clear                      #the post is already accepted by other one 
              if Invite.exists?(:post_id => @post.id, :invite_status => "accepted")
                 flash[:error] = "this post is already accepted by other"
                 redirect_to index_path
              else
                @admin = Admin.where(status: "available", role: "proof_reader")
                @add = @admin.ids
                if @admin.length != 0               #sending the requests if proofreaders are available
                  for i in 0..@admin.length - 1
                    if Invite.exists?(:post_id => @post.id,:reciever_id => @add[i])
                      next
                    else
                      @invit = Invite.new
                      @invit.post_id = @id
                      @invit.host_id = current_admin.id
                      @invit.reciever_id = @add[i]
                      @invit.invite_status = "pending"
                      @invit.read_status = "pending"
                      @invit.error_count = 0
                      if @invit.save
                         @admin = Admin.find(@add[i])
                         UserMailer.with(admin_id: @admin.id, post_id: @id).invite_email.deliver_now
                         @arr << @admin.email
                       end
                    end      
                  end 
                  if !@arr.empty?
                    flash[:success] = "invitation sent successfully to #{@arr}"
                    redirect_to index_path
                  else
                    flash[:error] = "invitations already sent"
                    redirect_to index_path
                  end
                else
                  flash[:success] = "all proofreaders are busy"
                    redirect_to index_path
                end
              end
            else
              flash[:error] = "post proofreading is completed"
              redirect_to index_path
            end
          end
         end
        end           
      end
    end 
  end
end