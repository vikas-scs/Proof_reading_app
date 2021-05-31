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
            puts params.inspect
            @id = params[:id]
            puts @id
            @post = Post.find(@id)
            if @post.status == "pending" 
              @arr = Array.new
              @arr.clear
              puts "coming here"
              if Invite.exists?(:post_id => @post.id, :invite_status => "accepted")
                puts "yessssssssss"
                 flash[:error] = "this post is already accepted by other"
                 redirect_to index_path
              else
               @admin = Admin.where(status: "available", role: "proof_reader")
               @add = @admin.ids
               puts @add
               if @admin.length != 0
                for i in 0..@admin.length - 1
                  if Invite.exists?(:post_id => @post.id,:reciever_id => @add[i], :invite_status => "reject")
                      puts "hellooooooooooo"
                      next
                  else
                      puts "its comming here"
                      @invit = Invite.new
                      @invit.post_id = @id
                      @invit.host_id = current_admin.id
                      @invit.reciever_id = @add[i]
                      @invit.invite_status = "pending"
                      @invit.read_status = "pending"
                      @invit.error_count = 0
                      @invit.save
                      @admin = Admin.find(@add[i])
                      @arr << @admin.email
                    end      
                end 
                if !@arr.empty?
                 flash[:success] = "invitation sent successfully to #{@arr}"
                 redirect_to index_path
                end
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