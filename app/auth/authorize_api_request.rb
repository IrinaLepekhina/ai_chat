# app/auth/authorize_api_request.rb

# The AuthorizeApiRequest class is responsible for authorizing an API request.
class AuthorizeApiRequest
  def initialize(headers = {}, cookies = nil)
    @headers = headers
    @cookies = cookies
  end

  # Service entry point - return valid user object
  def call
    {
      user: user
    }
  end

  private

  attr_reader :headers, :cookies

  def user
    # Check if user is in the database. Memoize user object
    @user ||= User.find(decoded_auth_token[:user_id]) if decoded_auth_token
    # Handle user not found
  rescue ActiveRecord::RecordNotFound => e
    # Raise custom error
    raise(
      ExceptionHandler::InvalidToken,
      "#{Message.invalid_token} #{e.message}"
    )
  end

  # Decode authentication token
  def decoded_auth_token
    @decoded_auth_token ||= JsonWebToken.decode(http_auth_token)
  end

  # Check for token in `Authorization` header or cookies
  def http_auth_token
    # Check if token is present
    cookie_token || header_token || missing_token_error
  end

  def cookie_token
    # Retrieve token from cookies if available
    cookies.signed[:jwt] if cookies.present?
  end
  
  def header_token
    # Extract token from `Authorization` header if present
    authorization_header = headers['Authorization']
    if authorization_header && authorization_header.start_with?('Bearer ')
      authorization_header.split(' ').last
    end
  end

  def missing_token_error
    # Raise error if token is missing in both header and cookies
    raise(ExceptionHandler::AuthenticationError, Message.unauthorized)
  end
end