module RailsAdmin
  module Config
    module Actions
      class AcceptAction < RailsAdmin::Config::Actions::Base
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
            
            if !params[:corrected].present?
               @post = Post.find(params[:post_id])
               @invite_id = params[:invite_id]
            else
              puts "helloooo"
              puts params.inspect
               @invite = Invite.find(params[:invite_id])
               @post = Post.find(@invite.post_id)
               @invite.read_status = params[:corrected]
               @invite.time_taken = params[:time_taken]
               @error_count = 0
               @post = Post.find(params[:post_id])
               pos  = @post.post.split(" ")
               cor = params[:corrected].split(" ")
               if pos.length < cor.length || pos.length == cor.length
                  count = pos - cor
                  @error_count = count.length
              end
              if pos.length > cor.length
                count = cor - pos
                  @error_count = count.length
              end
             @invite.error_count = @error_count
             @invite.invite_status = "accept"
             @post.status = "corrected"
             @post.save
             if @invite.save
                flash[:success] = "proof reading done successfully"
                redirect_to index_path
              end
            end
          end           
        end
      end
    end 
  end
end