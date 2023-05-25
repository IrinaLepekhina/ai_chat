# app/controllers/concerns/exception_handler.rb
# https://www.rubydoc.info/gems/rack/Rack/Utils

# This module can be included in Rails controllers to provide custom exception handling
module ExceptionHandler
  extend ActiveSupport::Concern
  include AuthenticationHelper
  # Define custom error subclasses - rescue catches `StandardErrors`

  class AuthenticationError < StandardError; end
  class MissingToken < StandardError; end
  class InvalidToken < StandardError; end

  included do
    # Define custom handlers
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity #422
    rescue_from ActionController::ParameterMissing, with: :render_parameter_missing #422

    rescue_from ActionView::MissingTemplate,     with: :render_not_found #RoutingError 404
    rescue_from ActiveRecord::RecordNotFound,    with: :render_not_found #RoutingError 404
    rescue_from ActionController::RoutingError,  with: :render_not_found #RoutingError 404
    rescue_from ActionController::UnknownFormat, with: :render_not_found #RoutingError 404

    rescue_from ExceptionHandler::AuthenticationError, with: :unauthorized_request #401
    rescue_from ExceptionHandler::MissingToken, with: :render_unprocessable_entity #422
    rescue_from ExceptionHandler::InvalidToken, with: :render_unprocessable_entity #422
    rescue_from ActionController::InvalidAuthenticityToken, with: :handle_invalid_authenticity_token # 422
  end

  private

  # RecordNotFound / RoutingError 404
  def render_not_found(exception)
    respond_to do |format|
      format.html { redirect_to root_url, notice: Message.not_found(message: exception.message) }
      format.json { json_response({ error: Message.not_found(message: exception.message) }, :not_found) }
      format.all { render body: nil, status: :not_found }
    end
  end

  # RecordInvalid 422
  def render_unprocessable_entity(exception)
    respond_to do |format|
      format.html { render :new }
      format.json { json_response({ error: Message.invalid(message: exception.message) }, :unprocessable_entity) }
    end
  end

  # ParameterMissing 422
  def render_parameter_missing(exception)
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path, alert: exception.message) }
      format.json { json_response({ error: Message.parameter_missing }, :unprocessable_entity) }
    end
  end

  # Unauthorized 401
  def unauthorized_request(exception)
    respond_to do |format|
      format.html { redirect_to api_login_path, alert: Message.invalid_credentials }
      format.json { json_response({  error: Message.invalid_credentials }, :unauthorized) }
    end
  end

  # Handle InvalidAuthenticityToken exception
  def handle_invalid_authenticity_token(exception)
    sign_out_user
    respond_to do |format|
      format.html { redirect_to root_url, alert: Message.invalid_authenticity_token }
      format.json { json_response({ error: Message.invalid_authenticity_token }, :unprocessable_entity) }
    end
  end
end