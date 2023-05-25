# app/controllers/concerns/authentication_helper.rb

# The AuthenticationHelper module provides helper methods for user authentication.
module AuthenticationHelper
  # Sign out the user by clearing session data and deleting the JWT token cookie.
  def sign_out_user
    session.clear
    cookies.delete(:jwt)
    # cookies.delete(:jwt), same_site: :none, secure: Rails.env.production?)
  end
end