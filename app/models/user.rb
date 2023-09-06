# app/models/user.rb

class User < ApplicationRecord
  has_many :conversations

  validates_presence_of :email, :nickname, :password_digest
  validates_uniqueness_of :email, :nickname

  validates :nickname, exclusion: { in: %w(admin administrator), message: "is reserved" }
  validates :nickname, format: { with: /\A[a-zA-Z0-9_]+\z/  , message: "only allows letters, numbers, and underscores" }

  # encrypt password
  has_secure_password
end
