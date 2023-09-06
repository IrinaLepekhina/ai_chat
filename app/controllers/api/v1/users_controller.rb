# frozen_string_literal: true

# app/controllers/api/v1/users_controller.rb
module Api
  module V1
    class UsersController < ApiController
      include AuthenticationHelper

      skip_before_action :authorize_request, only: [:new, :create], raise: false
      skip_before_action :verify_authenticity_token, only: [:create]
      
      def new
        @user = User.new
      end
      
      def create
        @user = User.new(user_params)

        log_info("Attempting to save user: #{user_params.inspect}")
        return unless @user.save!

        tokens = AuthenticateUser.new(@user.email, @user.password).call
        handle_token(tokens)
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