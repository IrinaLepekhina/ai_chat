# app/lib/json_web_token.rb
class JsonWebToken
  # secret to encode and decode token
  HMAC_SECRET = ENV.fetch('SECRET_KEY_BASE')

  def self.encode(payload, exp = 24.hours.from_now)
    # set expiry to 24 hours from creation time
    payload[:exp] = exp.to_i
    # sign token with application secret
    JWT.encode(payload, HMAC_SECRET)
  end

  def self.decode(token)
    # get payload; first index in decoded Array
    body = JWT.decode(token, HMAC_SECRET)[0]
    HashWithIndifferentAccess.new body
    # rescue from all decode errors
  rescue JWT::ExpiredSignature => e
    raise ExceptionHandler::InvalidToken, e.message
  rescue JWT::DecodeError => e
    raise ExceptionHandler::InvalidToken, e.message
  rescue JWT::VerificationError => e
    raise ExceptionHandler::InvalidToken, e.message
  end
end
