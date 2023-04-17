# This module can be included in Rails controllers to provide custom exception handling
# https://www.rubydoc.info/gems/rack/Rack/Utils

module Exceptionable
  extend ActiveSupport::Concern
  # Define custom error subclasses - rescue catches `StandardErrors`
  # class AuthenticationError < StandardError; end

  included do
    # Define custom handlers
    rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity
    rescue_from ActionController::ParameterMissing, with: :render_parameter_missing

    rescue_from ActionView::MissingTemplate,     with: :render_not_found
    rescue_from ActiveRecord::RecordNotFound,    with: :render_not_found
    rescue_from ActionController::RoutingError,  with: :render_not_found
    rescue_from ActionController::UnknownFormat, with: :render_not_found

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
end
