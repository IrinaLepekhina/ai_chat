# app/auth/authenticate_user.rb

# The AuthenticateUser class is responsible for authenticating a user
class AuthenticateUser
  def initialize(email, password)
    @email = email
    @password = password
  end

  # Service entry point
  def call
    # Call the user method to verify credentials and return a JWT if valid
    JsonWebToken.encode(user_id: user.id) if user
  end

  private

  attr_reader :email, :password

  # Verify user credentials
  def user
    # Find a user in the database with the provided email
    user = User.find_by(email: email)
    
    # Return the user object if found and the password is valid
    return user if user && user.authenticate(password)

    # Raise an AuthenticationError if credentials are invalid
    raise(ExceptionHandler::AuthenticationError, Message.invalid_credentials)
  end
end