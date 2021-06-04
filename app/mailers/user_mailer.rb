class UserMailer < ApplicationMailer
   def welcome_email
   	@post = Post.find(params[:post_id])
    @user = User.find(params[:user_id])
    mail(to: @user.email, subject: 'post info')
  end
   def invite_email
   	@post = Post.find(params[:post_id])
    @admin = Admin.find(params[:admin_id])
    mail(to: @admin.email, subject: 'invitation for proofread')
  end
   def fine_email
   	@post = Post.find(params[:post_id])
    @admin = Admin.find(params[:admin_id])
    @fine = params[:fine]
    mail(to: @admin.email, subject: 'fine for rejecting')
  end
  def accept_email
    @post = Post.find(params[:post_id])
    @user = User.find(@post.user_id)
    mail(to: @user.email, subject: 'Accepting proofreading')
  end
end
