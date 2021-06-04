class CuponController < ApplicationController
	def index
		@coupon = Cupon.all
	end
  def update
     @cupons = Cupon.all
    @post = Post.find(params[:id])
    if @post.status == "done"
      puts params.inspect
      @post = Post.find(params[:id])
      if @post.cupon_id.present?
       @cupon = Cupon.find(@post.cupon_id)
     end
     @state = Statement.where(post_id: @post.id, action: "distributing money for proofread")
       @statement = @state.ids
    puts @statement
    @statement1 = Statement.find(@statement.first)
    puts @statement1.amount
    @statement2 = Statement.find(@statement.second)
    puts @statement2.amount
    @invites = Invite.where(post_id: @post.id)
    @invit = @invites.ids
    @invite = Invite.find(@invit.first)
    @admin = Admin.find(@invite.reciever_id)
    puts @post.post
  end
  if @post.cupon_id.present?
   @cupon = Cupon.find(@post.cupon_id)
  end
    if Invite.exists?(post_id: params[:id], invite_status: "accept")                        #checking whether post is exist in invitations
      @invi = Invite.where(post_id: params[:id], invite_status: "accept")
      @idd = @invi.ids
         @invite = Invite.find(@idd.first)                             #getting invitation id from post status
        puts @invite.invite_status    
      end
     respond_to do |format|
      format.html
      format.pdf do
        render template: "cupon/update.html.erb",            #rendering pdf file through view
        layout: 'pdf.html.erb',
        pdf: "invoice",
        disposition: 'attachment'                            #providing  downloading option
        return
      end
    end
  end
end
