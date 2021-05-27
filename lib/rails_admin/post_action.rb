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
            @posts = Post.all
            puts @posts
            @users = User.all
            @admins = Admin.all
            puts params.inspect
            if params[:host_id].present?
                @arr = Array.new
                @arr.clear
                @admins.each do |admin|
                  if admin.status == "available"
                    @invite = Invite.new
                    @invite.post_id = params[:post_id].to_i
                    @invite.host_id = params[:host_id].to_i
                    @invite.reciever_id = admin.id
                    @invite.invite_status = params[:i_status]
                    @invite.read_status = params[:r_status]
                    @invite.error_count = params[:e_count]
                    if Invite.exists?(:reciever_id => params["reciever_id"].to_i, :post_id => params["post_id"].to_i)
                     next
                    end
                    @arr << admin.email
                    @invite.save
                  end
                end
                if !@arr.empty?
                   flash[:success] = "invitation sent successfully to #{@arr}"
                   redirect_to index_path
                 else
                   flash[:error] = "invitation already sent"
                   redirect_to index_path
                 end
            end           
          end
        end
      end
    end 
  end
end