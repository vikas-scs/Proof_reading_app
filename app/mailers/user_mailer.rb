class UserMailer < ApplicationMailer
   def welcome_email
   	@post = Post.find(params[:post_id])
    @user = User.find(params[:user_id])
    mail(to: @user.email, subject: 'post info')
  end
end
