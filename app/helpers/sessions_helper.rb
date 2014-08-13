module SessionsHelper
	def sign_in(user)
		session[:remember_token] = user.id
		self.current_user = user
	end	

	def current_user=(user)
    	@current_user = user
  	end

  	def current_user
  		@current_user ||= User.find(session[:remember_token]) if session[:remember_token]
  	end

  	def signed_in? 
  		!current_user.nil?
  	end

  	def destroy
  		sign_out
  		redirect_to root_url
  	end

  	def sign_out
  		session[:remember_token] = nil
  		self.current_user = nil
  	end
end
