# app/controllers/api_controller.rb

class ApiController < ApplicationController
  include ::ActionController::Cookies
  # to use the default application layout for API views.
  layout 'application'

  # to handle exceptions and HTTP responses, respectively
  include ExceptionHandler
  include Response
  include Api
  
  before_action :authorize_request

  # Accessor for the current_user attribute.
  attr_accessor :current_user

  # Make current_user accessible in view templates.
  helper_method :current_user

  private

  # Check for valid request token and return user
  def authorize_request
    @current_user = (AuthorizeApiRequest.new(request.headers, cookies).call)[:user]
  end
end
