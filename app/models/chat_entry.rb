# app/models/chat_entry.rb

# Represents a chat entry within a conversation.
class ChatEntry < ApplicationRecord
  belongs_to :conversation
  has_one    :ai_response, dependent: :nullify

  validates :conversation, presence: true
  validates :content, presence: true

  def user
    conversation.user
  end
end
