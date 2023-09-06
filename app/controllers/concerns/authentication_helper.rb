# app/controllers/concerns/authentication_helper.rb

# The AuthenticationHelper module provides helper methods for user authentication.
module AuthenticationHelper
  include Loggable

  def sign_out_user
    log_info("Signing out user")
    
    session.clear
    cookies.delete(:jwt)
    # cookies.delete(:jwt), same_site: :none, secure: Rails.env.production?)

    log_info("User signed out and JWT cookie deleted")
  end

  private

  def handle_token(tokens)
    jwt_token = tokens[:jwt]
    refresh_token = tokens[:refresh]

    log_info("Handling tokens: jwt, refresh")

    respond_to do |format|
      format.html do
        cookies.signed[:jwt] = { value: jwt_token, expires: 1.week.from_now, httponly: true }
        log_info("JWT token set as signed cookie", jwt: jwt_token)
        redirect_to root_path, notice: Message.logged_in
      end
      format.json do
        response.headers['Authorization'] = "Bearer #{jwt_token}"
        log_info("Setting JWT token in response header")
        json_response({
          message: Message.logged_in,
          refresh_token: refresh_token
        }, :created)
      end
    end
  end
end