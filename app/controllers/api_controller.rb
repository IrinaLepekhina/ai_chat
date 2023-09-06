# app/controllers/api_controller.rb

class ApiController < ApplicationController
  include ::ActionController::Cookies
  # to use the default application layout for API views.
  layout 'application'

  # to handle exceptions and HTTP responses, respectively
  include ExceptionHandler
  include Response
  include Api
  include Loggable
  
  before_action :authorize_request

  # Accessor for the current_user attribute.
  attr_accessor :current_user

  # Make current_user accessible in view templates.
  helper_method :current_user

  private

  # Check for valid request token and return user
  def authorize_request
    log_info("authorizing request")

    # Log headers
    desired_headers = ['HTTP_ACCEPT', 'HTTP_USER_AGENT', 'HTTP_AUTHORIZATION']
    headers_info = request.headers.env.select { |k, v| desired_headers.include?(k) && v.present? }

    # Check if HTTP_AUTHORIZATION exists and modify its value to display only "Bearer"
    if headers_info['HTTP_AUTHORIZATION']&.include?("Bearer")
      headers_info['HTTP_AUTHORIZATION'] = "Bearer ..."
    end

    log_info("Headers: #{headers_info}")

    @current_user = (AuthorizeApiRequest.new(request.headers, cookies).call)[:user]
  end
end