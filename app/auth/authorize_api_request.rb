# app/auth/authorize_api_request.rb

# The AuthorizeApiRequest class is responsible for authorizing an API request.
class AuthorizeApiRequest
  include Loggable

  def initialize(headers = {}, cookies = nil)
    @headers = headers
    @cookies = cookies
    log_info("Initializing AuthorizeApiRequest")
  end

  def call
    log_info("Authorizing API request")
    {
      user: user
    }
  end

  private

  attr_reader :headers, :cookies

  def user
    user ||= User.find(decoded_auth_token[:user_id]) if decoded_auth_token
    log_info("User found")
    user
  rescue ActiveRecord::RecordNotFound => e
    log_info("User not found in the database: #{e.message}")
    raise(
      ExceptionHandler::InvalidToken, "#{Message.invalid_token} #{e.message}")
  end
  
  def decoded_auth_token
    @decoded_auth_token ||= JsonWebToken.decode(http_auth_token)
  rescue => e
    log_error("Error decoding authentication token: #{e.message}")
    raise
  end
  
  def http_auth_token
    token = cookie_token || header_token || missing_token_error
    log_info("Using HTTP auth token") if token
    token
  end
  
  def cookie_token
    token = cookies.signed[:jwt] if cookies.present?
    log_info("Retrieved token from cookies") if token
    token
  end
  
  def header_token
    authorization_header = headers['Authorization']
    if authorization_header && authorization_header.start_with?('Bearer ')
      token = authorization_header.split(' ').last
      log_info("Retrieved token from Authorization header") if token
      token
    end
  end

  def missing_token_error
    log_info("Authentication token missing in both header and cookies.")
    raise(ExceptionHandler::AuthenticationError, Message.unauthorized)
  end
end