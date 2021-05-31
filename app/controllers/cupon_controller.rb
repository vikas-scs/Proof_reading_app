class CuponController < ApplicationController
	def index
		@coupon = Cupon.all
	end
	def show
     
	end
  def hello
     @cupons = Cupon.all
    @post = Post.find(params[:id])
    if @post.status == "done"
       @cupon = Cupon.find(@post.cupon_id)
  
    @state = Statement.where(post_id: @post.id)
    @statement = @state.ids
    puts @statement
    @statement1 = Statement.find(@statement[0])
    @statement2 = Statement.find(@statement[1])
  end
    @invites = Invite.where(post_id: @post.id)
    @invit = @invites.ids
    @invite = Invite.find(@invit[0])
    @admin = Admin.find(@invite.reciever_id)
    puts @post.post
    if Invite.exists?(post_id: params[:id], invite_status: "accept")                        #checking whether post is exist in invitations
      @invi = Invite.where(post_id: params[:id], invite_status: "accept")
      @idd = @invi.ids
         @invite = Invite.find(@idd[0])                             #getting invitation id from post status
        puts @invite.invite_status
       if @invite.error_count >= 0
         @post.post = @invite.read_status
         @post.status = "corrected"                                #assigning status  for  post if proofreading is done  
         @post.save
      end
     end
     respond_to do |format|
      format.html
      format.pdf do
        render template: "cupon/hello.html.erb",            #rendering pdf file through view
        layout: 'pdf.html.erb',
        pdf: "post_invoice",
        disposition: 'attachment'                            #providing  downloading option
        return
      end
    end
  end
end
