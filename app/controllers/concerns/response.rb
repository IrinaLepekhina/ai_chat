# Response is a module that provides a helper method for rendering JSON responses in controllers.

module Response
  def json_response(object, status = :ok)
    render json: object, status: status
  end
end
