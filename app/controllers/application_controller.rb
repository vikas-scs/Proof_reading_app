class ApplicationController < ActionController::Base
	def after_sign_in_path_for(resource)
   	puts "login path"
   	puts resource.class
    # check for the class of the object to determine what type it is
    case resource.class.to_s
    when "User"
    	root_path
      # new_user_session_path  
    when "Admin"
      puts "hello"
    	rails_admin_path
      # new_admin_session_path
    end
  end
end
