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

end
