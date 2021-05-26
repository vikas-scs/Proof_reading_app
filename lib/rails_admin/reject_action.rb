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
            puts params.inspect
            if !params[:corrected].present?
               @post = Post.find(params[:post_id])
               @invite_id = params[:invite_id]
            else
               @invite = Invite.find(params[:invite_id])
               @invite.read_status = params[:corrected]
               @error_count = 0
               @post = Post.find(params[:post_id])
               pos  = @post.post.split(" ")
               cor = params[:corrected].split(" ")
               for i in 0..pos.length-1 
                  if pos[i] != cor[i]
                    @error_count += 1
                  end
                end
                @invite.error_count = @error_count
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