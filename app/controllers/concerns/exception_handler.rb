# app/controllers/concerns/exception_handler.rb
# https://www.rubydoc.info/gems/rack/Rack/Utils

# This module can be included in Rails controllers to provide custom exception handling
module ExceptionHandler
  extend ActiveSupport::Concern
  include AuthenticationHelper

  # Define custom error subclasses - rescue catches `StandardErrors`
  class AuthenticationError     < StandardError; end
  class InvalidToken            < StandardError; end
  class LanguageServiceError    < StandardError; end
  class TextDirectoryEmptyError < StandardError; end

  included do
    # Define custom handlers
    rescue_from ActiveRecord::RecordInvalid,        with: :render_unprocessable_entity #422
    rescue_from ActionController::ParameterMissing, with: :render_parameter_missing    #422

    rescue_from ActionView::MissingTemplate,     with: :render_not_found #RoutingError 404
    rescue_from ActiveRecord::RecordNotFound,    with: :render_not_found #RoutingError 404
    rescue_from ActionController::RoutingError,  with: :render_not_found #RoutingError 404
    rescue_from ActionController::UnknownFormat, with: :render_not_found #RoutingError 404

    rescue_from ExceptionHandler::InvalidToken,            with: :invalid_authenticity_token # 401
    rescue_from ExceptionHandler::AuthenticationError,     with: :unauthorized_request   # 401
    rescue_from ExceptionHandler::LanguageServiceError,    with: :language_service_error # 403
    rescue_from ExceptionHandler::TextDirectoryEmptyError, with: :text_directory_empty   # 500
    rescue_from Faraday::ConnectionFailed,                 with: :connection_failed      # 500
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
      format.html do
        # For ChatEntriesController, redirect to conversation show page
        if self.is_a?(Api::V1::ChatEntriesController)
          flash[:alert] = exception.message
          redirect_to api_conversation_path(@chat_entry.conversation)
        else
          # For other controllers, render :new
          render :new
        end
      end
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

  # Unauthorized 401
  def invalid_authenticity_token(exception)
    sign_out_user
    respond_to do |format|
      format.html { redirect_to root_url, alert: Message.invalid_authenticity_token }  
      format.json { json_response({ error: Message.invalid_authenticity_token }, :unauthorized) }
    end
  end
  
  # Forbidden 403
  def language_service_error(exception)
    respond_to do |format|
      format.html { redirect_to api_conversation_path(@conversation), alert: Message.insufficient_quota(message: exception.message) }
      format.json { json_response({ error: Message.insufficient_quota(message: exception.message) }, :forbidden) }
    end
  end

  # InternalServerError 500
  def text_directory_empty(exception)
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path, alert: Message.try_again_later) }
      format.json { json_response({ error: exception.message }, :internal_server_error) }
    end
  end

  # InternalServerError 500
  def connection_failed(exception)
    respond_to do |format|
      format.html { redirect_to root_path, alert: Message.connection_failed(message: exception.message) }
      format.json { json_response({ error: Message.connection_failed(message: exception.message) }, :internal_server_error) }
    end
  end
end