class User < ApplicationRecord
  # validates :password, confirmation: true

  validates_presence_of :email, :nickname, :password_digest
  validates_uniqueness_of :email, :nickname

  validates :nickname, exclusion: { in: %w(admin administrator), message: "is reserved" }
  validates :nickname, format: { with: /\A[a-zA-Z0-9]+\z/ , message: "only leters and numbers" }

  # encrypt password
  has_secure_password
  #has_many :products, foreign_key: :created_by
end
