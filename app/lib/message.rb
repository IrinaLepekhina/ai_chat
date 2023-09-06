# app/lib/message.rb

# Message is a utility class for generating common text messages used throughout the application.
module Message
  # 201 => success
  def self.record_created
    'Record created successfully'
  end

  # exceptions
  # 404 => 'Not Found'
  def self.not_found(message, record = 'record')
    "Sorry, #{record} not found: #{message}."
  end

  #  422 => 'Unprocessable Entity'
  def self.invalid(message, record = 'record')
    "Invalid parameters submitted for #{record} creation: #{message}."
  end

  # 422 => 'Unprocessable Entity'
  def self.parameter_missing
    'Required parameters are missing or empty.'
  end

  def self.invalid_credentials
    'Invalid credentials'
  end

  def self.invalid_token
    'Invalid token'
  end

  def self.missing_token
    'Missing token'
  end

  def self.unauthorized
    'Unauthorized request'
  end

  def self.account_created
    'Account created successfully'
  end

  def self.logged_in
    'You are successfully logged in'
  end

  def self.logged_out
    'You are logged out'
  end

  def self.account_not_created
    'Account could not be created'
  end

  def self.expired_token
    'Sorry, your token has expired. Please login to continue.'
  end

  def self.invalid_authenticity_token
    'Invalid authenticity token'
  end

  def self.insufficient_quota(message)
    "Sorry, #{message[:message]}"
  end

  def self.connection_failed(message)
    "Check your internet connection, #{message[:message]}"
  end

  def self.try_again_later
    'An error occurred while processing your request. Please try again later.'
  end
end
