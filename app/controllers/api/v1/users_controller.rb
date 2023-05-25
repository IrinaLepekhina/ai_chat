# frozen_string_literal: true

# app/controllers/api/v1/users_controller.rb
module Api
  module V1
    class UsersController < ApiController

      skip_before_action :authorize_request, only: [:new, :create], raise: false
      skip_before_action :verify_authenticity_token, only: [:create]

      def new
        @user = User.new
      end
      
      # POST api/signup
      # return authenticated token upon signup
      def create
        @user = User.new(user_params)

        return unless @user.save!

        # Authenticate the user and obtain an authentication token
        auth_token = AuthenticateUser.new(@user.email, @user.password).call
                
        respond_to do |format|
          format.html do
            # Set the JWT token as a signed cookie
            cookies.signed[:jwt] = { value: auth_token, expires: 1.week.from_now, httponly: true }
            redirect_to root_url, notice: Message.account_created
          end
          format.json do
            # Set the JWT token in the 'Authorization' header
            response.headers['Authorization'] = "Bearer #{auth_token}"
            json_response({ message: Message.account_created }, :created)
          end
        end
      end
      
      private
      
      def user_params
        params.require(:user).permit(
          :name, 
          :email, 
          :nickname, 
          :password
          )
        end
      end
    end 
  end

  # def store_current_user_in_cookie(user)
  #   cookies.signed[:user_id] = { value: user.id, expires: 1.week.from_now }
  # end
  # store_current_user_in_cookie(@current_user) # Store user in cookie