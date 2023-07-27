# app/controllers/authentication_controller.rb
module Api
  # The AuthenticationController handles user authentication.
  class AuthenticationController < ApiController
    # # def sign_out_user
    include AuthenticationHelper

    # Skip CSRF token verification for the login action
    skip_before_action :verify_authenticity_token, only: [:login]
    # Skip authorization check for login and new actions
    skip_before_action :authorize_request, only: [:login, :new], raise: false

    # Display the login form.
    def new; end

    # POST /api/login
    # Authenticate the user and return an authentication token.
    def login
      auth_token = AuthenticateUser.new(auth_params[:email], auth_params[:password]).call
      
      respond_to do |format|
        format.html do
          # Set JWT token as a signed cookie
          cookies.signed[:jwt] = { value: auth_token, expires: 1.week.from_now, httponly: true}#, same_site: :none, secure: Rails.env.production? }
          redirect_to root_path, notice: Message.logged_in
        end
        format.json do
          # Set JWT token in the response header for API clients
          response.headers['Authorization'] = "Bearer #{auth_token}"
          json_response({ message: Message.logged_in }, :created)
        end
      end
    end
    
    # POST /api/logout
    # Logs out the user and revokes the authentication token.
    def logout
      sign_out_user 

      respond_to do |format|
        format.html { redirect_to root_path, notice: Message.logged_out }
        format.json { json_response({ message: Message.logged_out }, :deleted) }
      end
    end

    private

    def auth_params
      params.require(:auth_params).permit(:email, :password)
    end

    # Call the sign_out_user method from AuthenticationHelper
    def sign_out_user
      super
    end
  end
end
