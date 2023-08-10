# app/models/conversation.rb

# Represents a conversation between a user and the AI.
class Conversation < ApplicationRecord
  belongs_to :user
  has_many :chat_entries, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :ai_responses, dependent: :nullify

  validates :user, presence: true

  # Adds a new message to the conversation.
  def add_message(content)
    chat_entries.create(content: content)
  end
end