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
    @statement1 = Statement.where(post_id: @post.id, action: "distributing money for proofread").first
    @statement2 = Statement.where(post_id: @post.id, action: "distributing money for proofread").second
    @invite = Invite.where(post_id: @post.id).first
    @admin = Admin.find(@invite.reciever_id)
  end
  if @post.cupon_id.present?
   @cupon = Cupon.find(@post.cupon_id)
  end
    if Invite.exists?(post_id: params[:id], invite_status: "accept")                        #checking whether post is exist in invitations
         @invite = Invite.where(post_id: params[:id], invite_status: "accept").first                             #getting invitation id from post status   
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
