# app/auth/authenticate_user.rb

# The AuthenticateUser class is responsible for authenticating a user
class AuthenticateUser
  include Loggable
  
  def initialize(email, password)
    @email = email
    @password = password
  end

  # Service entry point
  def call
    if user
      log_info("User authenticated successfully", user_id: user.id, email: email)
      {
        jwt: JsonWebToken.encode(user_id: user.id),
        refresh: generate_refresh_token_for(user)
      }
    end
  rescue ExceptionHandler::AuthenticationError => e
    log_exception(e)
    log_error("Authentication failed", email: email)
    raise e
  end

  private

  attr_reader :email, :password

  def generate_refresh_token_for(user)
    # Log generation of a refresh token
    log_info("Generated refresh token for user", user_id: user.id)
    
    # This is a placeholder. Implement logic for generating/storing the refresh token.
    SecureRandom.hex(20)
  end

  # Verify user credentials
  def user
    # Find a user in the database with the provided email
    user = User.find_by(email: email)
    
    # Return the user object if found and the password is valid
    return user if user && user.authenticate(password)

    # Log failed authentication attempt
    log_error("Failed to authenticate user", email: email)
    
    # Raise an AuthenticationError if credentials are invalid
    raise(ExceptionHandler::AuthenticationError, Message.invalid_credentials)
  end
end